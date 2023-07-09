unit class Github::PublicKeys;

# the Github public key lines go here
my constant %gh-keys = set <

'github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl'

'github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg='

'github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk='

>;

method add-keys($go?) {
    unless %*ENV<HOME>:exists {
        die "FATAL: Environment variable '\$HOME' is not defined."
    }
    my $home-dir = %*ENV<HOME>;
    my $ssh-dir = "$home-dir/.ssh";
    my $khfil = "$ssh-dir/known_hosts";
    # shorter version for reporting:
    my $khf   = "~/.ssh/known_hosts";
    unless $khfil.IO.r {
        die "FATAL: No '$khfil' exists."
    }

    # tell actions to be taken
    if not $go.defined {
        print qq:to/HERE/;
        Usage: gh-add-keys go
        
        Adds the latest Github public ssh keys to your
          '$khf' 
        file if they are not there already.

        Reports actions taken.
        HERE
        exit;
    }

    # check for existing Github lines
    my $github = 'github.com';

    my %found;
    for $khfil.IO.lines -> $key {
        if %gh-keys{$key}:exists {
            # good, log it
            %found{$key} = 1;
        }
    }

    my $nf = %found.elems;
    my $nk = %gh-keys.elems;

    if $nf == $nk {
        # all is cool
        print qq:to/HERE/;
        Good, your current '$khf'
          file has the new keys already.
        No further action is required.
        HERE
        exit;
    }

    if $nf < $nk {
        # one or more are needed
        print qq:to/HERE/;
        Found $nf new keys, will add {$nk - $nf} to the
        '$khf' file.
        HERE
    }

    # all is okay, add missing key lines to the end
    my %added;  # keys added
    my $fh = open $khfil, :a; # append
    for %gh-keys.keys -> $key {
        next if %found{$key}:exists;
        %added{$key} = 1;
        $fh.say: $key;
    }
    $fh.close;

    print qq:to/HERE/;
    Success, check your '$khf' file for the {%added.elems} added keys:
    HERE
    say "  $_" for %added.keys;
}
