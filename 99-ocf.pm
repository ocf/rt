Set($WebDomain, 'rt.ocf.berkeley.edu');
Set($WebBaseURL , 'https://rt.ocf.berkeley.edu');
Set($WebPath, '');
Set($WebPort, 443);

Set($CorrespondAddress , 'root@ocf.berkeley.edu');
Set($CommentAddress , 'root@ocf.berkeley.edu');
Set($SetOutgoingMailFrom, 1);

# Use external authentication provided by mod_auth_kerb
Set($WebRemoteUserAuth , 1);
Set($WebFallbackToRTLogin, 1);
# create users automatically if no user matching REMOTE_USER is found
Set($WebRemoteUserAutocreate, 1);
Set($WebRemoteUserGecos, undef);

# Plugins
Set(@MailPlugins, qw(Auth::MailFrom Action::CommandByMail));
Plugin('RT::Extension::CommandByMail');
Plugin('RT::Extension::MergeUsers');
Plugin('RT::Extension::Tags');

# Make links clicky
Set(@Active_MakeClicky, qw(httpurl_overwrite));

# Non-blank To addresses
Set($UseFriendlyToLine, 1);

# Enable fulltext search without indexes.
# TODO: set up indexing; requires a regular cronjob/chronos task to update the
# indices
Set( %FullTextSearch,
    Enable     => 1,
    Indexed    => 0
);

# Use wrapped plain text instead of HTML email
Set($MessageBoxRichText, undef);
Set($PreferRichText, undef);
Set($MessageBoxWrap, 'HARD');
Set($MessageBoxWidth, 72);

# Automatically add CC from original email
Set($ParseNewMessageForTicketCcs, 1);

# Show more than 12000 characters (the default) before getting a message about
# the message body being too large
Set($MaxInlineBody, 100000);

# Enable a profiler to show how long page loads take and what they spend the
# most time on so we can try to make RT faster to load
use MasonX::Profiler;
Set(@MasonParameters, (preamble => 'my $p = MasonX::Profiler->new($m, $r);'));
