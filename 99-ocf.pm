Set($WebDomain, 'rt.ocf.berkeley.edu');
Set($WebBaseURL , 'https://rt.ocf.berkeley.edu');
Set($WebPath, '');
Set($WebPort, 443);

Set($CorrespondAddress , 'root@ocf.berkeley.edu');
Set($CommentAddress , 'root@ocf.berkeley.edu');
Set($SetOutgoingMailFrom, 1);

Set($rtname, 'OCF');
Set($Organization, 'rt.OCF.Berkeley.EDU');

# Use external authentication provided by mod-auth-openidc
Set($WebRemoteUserAuth , 1);
Set($WebFallbackToRTLogin, 1);
# create users automatically if no user matching REMOTE_USER is found
Set($WebRemoteUserAutocreate, 1);
Set($WebRemoteUserGecos, undef);

Set($ExternalInfoPriority, ['ldap']);
# Allow non-LDAP users (e.g. external Requestors) to be created
Set($AutoCreateNonExternalUsers, 1);
# Fetch EmailAddress from the ocfEmail LDAP attribute
Set($ExternalSettings, {
	'ldap' => {
		'type'             =>  'ldap',
		'server'           =>  'ldaps://ldap.ocf.berkeley.edu',
		'tls'              => {
		    'verify' => 'require',
		    'cafile' => '/etc/ssl/certs/ca-certificates.crt',
		},
		'base'             =>  'ou=People,dc=OCF,dc=Berkeley,dc=EDU',
		'filter'           =>  '(objectClass=ocfAccount)',
		'attr_match_list'  => [
		    'Name',
		],
		'attr_map' => {
		    'Name'         => 'uid',
		    'EmailAddress' => 'ocfEmail',
		},
	},
} );

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

# Disable password prompt when creating authentication tokens
Set($DisablePasswordForAuthToken, 1);

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

# Switch to autocomplete box for owners. RT will do this automatically, but it
# should help with performance to just premptively set it here to not have to
# query for a list of users before the page loads.
Set($AutocompleteOwners, 1);

Set($DefaultSearchResultOrder, 'DESC');

# Disable search URL shortener
Set($EnableURLShortener, 0);
