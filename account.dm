#define ACCT( _ )		global.account[  _  ]
#define PWRD( _... )	md5( input( _ ) as password )


/client/authenticate = FALSE; \

/client/var/tmp/byond_authentication; \


/var/byond_account[]; /var/cid_address[]; \
/var/savefile/account; /account/var{ authentication; dateofcreation; byond_key; settings; lastloggedat; cid[0]; ip[0]; utc }; \


/world/New(){ ..(); \
	global.account = new /savefile("data/accounts.db"); \
	global.byond_account = ACCT( "#byond" ) || new; \
	global.cid_address = ACCT( "#cid" ) || new; \
}; \
/world/Del(){ ..(); \
	ACCT( "#byond" ) << global.byond_account; \
	ACCT( "#cid" ) << global.cid_address; \
}; \


/client/Del(){ ..(); \
	if( (ACCT(  src.key  ))?.dateofcreation == null ){ \
		global.account -= src.key; \
	} else (ACCT(  src.key  )).lastloggedat = world.realtime; \
}; \

/client/New(){ src.mob = new world.mob; var/username; \

	if( !( username = global.byond_account[ src.key ] \
	|| global.cid_address[ src.computer_id ] ) ) account_entry:{ \

		if( !account[( username = input( src, "username:__________\npassword:__________", "Login[.]" ) as text )] ){ \
			if( "Yes" != alert( "Account: [.] not found! would you like to make a new account?", "No", "Yes" ) ){ \
				. = "\n   * account name not found!"; \
				goto account_entry; \
			}; \

			ACCT(  username  ) = new /account; \

			. = ACCT(  username  ); \

			password_entry:{ \
				(.).authentication = PWRD( src, "Enter a password for the account", "Password for [username]" ); \
				if( (.).authentication != PWRD( src, "Re-Enter the password", "Password for [username]" ) ) \
					goto password_entry; \
			}; \

			(.).dateofcreation = world.realtime; \
			ACCT(  username  ) = .; \

		} else if((ACCT(  username  )).authentication != PWRD( src, "username:[username]\npassword:__________")){ \
			. = "\n   * incorrect password!"; \
			goto account_entry; \
		}; \
	}; \

	src.byond_authentication = src.key; \
	src.key = username; \

	. ||= ACCT(  src.key  ); \

	(.).ip[ src.address ] = (.).cid[ src.computer_id ] = world.realtime; \
	(.).utc = src.timezone; \

	ACCT(  src.key  ) = .; \
	
	return src.mob; \
}


/client/verb/Options_Account(){ \
	switch( input( src, "","" ) as null|anything in list( "Toggle auto-login with BYOND key", "Add/Remove BYOND link", "Toggle auto-login with Current Computer") ){ \
		if( "Add/Remove BYOND link" ){ \
			. = ACCT( src.key ); \
			if( (.).byond_key ){ \
				(.).byond_key = null; \
				usr << "Current BYOND account was linked"; \
			} else { \
				(.).byond_key = src.byond_authentication; \
				usr << "The BYOND key was unlinked"; \
			}; \
			ACCT( src.key ) = .; \
		}; \
		if( "Toggle auto-login with BYOND key" ){ \
			global.byond_account[ src.byond_authentication ] = global.byond_account[ src.byond_authentication ] ? null : src.key; \
		}; \
		if( "Toggle auto-login Current Computer" ){ \
			global.cid_address[ src.computer_id ] = global.cid_address[ src.computer_id ] ? null : src.key; \
		}; \
	}; \
}
