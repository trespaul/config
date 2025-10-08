use std/log

# Check a git repo for the latest commit per branch, then execute a webhook
#
# Queries $repo_url with `git ls-remote --branches`, reads and writes
# from `state.nuon`, and sends POSTs to provided URLs, per branch.
#
# Environment variable take precedence over arguments.
def main [
  --repo-url: string = "https://github.com/nixos/nixpkgs"
    # URL of git repo to query with `git ls-remote` [env: REPO_URL]
  --branches: string = "[[branch hook]; [nixos-unstable localhost]]"
    # NUON (or JSON) string, column names `branch` and `hook` [env: BRANCHES]
  --log-level: int = 20
    # log level (10: debug, 20: info, … , 50: critical) [env: LOG_LEVEL]
  --state-directory: path = "."
    # where to save the state file [env: STATE_DIRECTORY, set by systemd]
] {
  log set-level $log_level

  let repo_url: string = $env.REPO_URL? | default $repo_url | validate-url

  let branches_with_hooks: table<branch: string, hook: string> = $env.BRANCHES?
    | default $branches
    | from nuon

  let branches: list<string> = $branches_with_hooks | get branch
  let branches_refs: list<string> = $branches | each { $"refs/heads/($in)" }

  let new_refs = ls-remote-branches $repo_url $branches
    | state-entries

  let state_filepath = $env.STATE_DIRECTORY?
    | default $state_directory
    | path join state.nuon

  let old_state = open-state $state_filepath $new_refs

  let last_updates = $branches_refs | each { |ref|
    $old_state | where ref == $ref | sort-by timestamp | last
  }

  let updated_refs = get-updated-refs $last_updates $new_refs

  update-state $state_filepath $old_state $updated_refs

  post-hooks $updated_refs $branches_with_hooks

  log info "done."
}


def ls-remote-branches [remote: string, branches: list<string>] {
  try {
    log info $"fetching new refs from repo ($remote)"
    git ls-remote --branches $remote ...($branches)
      | lines
      | split column "\t" hash ref
  } catch {
    log critical $"failed to fetch new refs from repo ($remote); exiting."
    exit 1
  }
}


def state-entries [] {
  let now = date now | date to-timezone UTC
  $in | each {{
    timestamp: $now,
    ref: $in.ref,
    hash: $in.hash
  }}
}


def validate-url []: string -> string {
  let repo_url: string = $in

  if ( $repo_url == null ) {
    log critical "no REPO_URL specified; exiting."
    exit 1
  }

  try {
    $repo_url | url parse | url join
  } catch {
    log critical "malformed REPO_URL; exiting."
    exit 1
  }

  log debug $"REPO_URL is ($repo_url)"

  $repo_url
}


def get-updated-refs [old new] {
  let updated = $old
    | rename -c {hash: old_hash, timestamp: old_timestamp}
    | join $new ref
    | where { $in.old_hash != $in.hash }
    | select timestamp ref hash

  if ( ( $updated | length ) == 0 ) {
    log info "no refs were updated since last check; done."
    exit 0
  }

  let fmt = $updated | get ref | str join ', '
  log debug $"these refs were updated since last check: ($fmt)"

  $updated
}


def post-hooks [updated_refs branches_with_hooks] {
  let messages = $updated_refs | each {
    let branch = $in.ref | path basename
    { branch: $branch,
      msg: $"($branch) is now at ($in.hash | str substring 0..7)"
    }
  }

  log debug $"messages:\n($messages | get msg | str join '\n')"
  log info "sending messages"

  $messages | each {
    # using $it.whatever directly gives variable not found?
    let branch = $in.branch
    let message = $in.msg
    let url = $branches_with_hooks | where branch == $branch | get hook | first
    http post $url --content-type application/json { content: $message }
  }
}


def open-state [state_filepath new_refs] {
  try {
    log debug $"trying to open state file ($state_filepath)"
    open $state_filepath
  } catch {
    log info $"no state file found, will create in ($state_filepath)"
    $new_refs | to nuon --raw | save $state_filepath
    log info "skipping update until next run; done."
    exit 0
  }
}


def update-state [state_filepath old new] {
  log debug $"writing updated state file to ($state_filepath)"
  $old
    | prepend $new
    | to nuon --raw
    | save -f $state_filepath
}
