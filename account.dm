#define ACCT( _ )		global.account[  _  ]
#define PWRD( _... )	md5( input( _ ) as password )


/client/authenticate = FALSE;


/var/account_linker[]; /var/byond_account[]; /var/cid_address[]
/var/savefile/account; /account/var{ authentication; dateofcreation; byond_key; settings; lastloggedat; cid[0]; ip[0]; utc }


/world/New(){ ..(); 
	global.account = new /savefile("data/accounts.db")
	global.account_linker = ACCT( "#linker" ) || new
	global.byond_account = ACCT( "#byond" ) || new
	global.cid_address = ACCT( "#cid" ) || new
}
/world/Del(){ ..(); 
	ACCT( "#linker" ) << global.account_linker
	ACCT( "#byond" ) << global.byond_account
	ACCT( "#cid" ) << global.cid_address
}


/client/Del(){ ..(); 
	if( (ACCT(  src.key  ))?.dateofcreation == null )
		global.account -= src.key
	else (ACCT(  src.key  )).lastloggedat = world.realtime
}

/client/New(){ src.mob = new world.mob; var/username

	if( global.account_linker[ src.key ] )
		username = global.account_linker[ src.key ]
		. = ACCT(  username  )
		global.account_linker -= src.key
		if( (.).byond_key == src.key && (.).authentication == PWRD( src, "Enter the password", "Password for [username]" ) )
			ACCT(  username  ) = .
		else username = null

	if(!username \
	&& !( username = global.byond_account[ src.key ] \
	|| global.cid_address[ src.computer_id ] )) account_entry:{

		if( !account[( username = input( src, "username:__________\npassword:__________", "Login[.]" ) as text )] )
			if( "Yes" != alert( "Account: [.] not found! would you like to make a new account?", "No", "Yes" ) )
				. = "\n   * account name not found!"
				goto account_entry

			ACCT(  username  ) = new /account

			. = ACCT(  username  )

			password_entry:{
				(.).authentication = PWRD( src, "Enter a password for the account", "Password for [username]" )
				if( (.).authentication != PWRD( src, "Re-Enter the password", "Password for [username]" ) )
					goto password_entry
			}

			(.).dateofcreation = world.realtime
			ACCT(  username  ) = .

		else if((ACCT(  username  )).authentication != PWRD( src, "username:[username]\npassword:__________"))
			. = "\n   * incorrect password!"
			goto account_entry
	}

	src.key = username

	. ||= ACCT(  src.key  )

	(.).ip[ src.address ] = (.).cid[ src.computer_id ] = world.realtime
	(.).utc = src.timezone

	ACCT(  src.key  ) = .
	
	return src.mob
}


/client/verb/Options_Account(){
	switch( input( src, "","" ) as null|anything in list( "set BYOND key for medals", "auto-login with BYOND key", "auto-login with Current Computer") )
		if( "set BYOND key for medals" )
			. = global.account[ src.key ]
			global.account_linker[ ( (.).byond_key = input( src, "Input a BYOND key and the next time it logs in you will be asked for the password to verify.", "" ) as text ) ] = src.key
			ACCT( src.key ) = .
		if( "auto-login with BYOND key" )
			. = global.account[ src.key ]
			if( (.).byond_key )
				global.byond_account[ (.).byond_key ] = src.key
		if( "auto-login Current Computer" )
			global.cid_address[ src.computer_id ] = src.key
}