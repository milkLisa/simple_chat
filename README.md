# Simple Chat

Use devise, faye, private_pub, thin, SMTP and SMS. 

Add rolify and cancancan to manage roles, and the first sign up user will be assigned as Admin.

## Preceding operation

1.[Install & Run MySQL](https://dev.mysql.com/downloads/installer/) (recommend MySQL 5.7.18)

2.Create a database, ex: chat

## Config

* `database.yml`: Database settings.

* `email.yml`: Mail server settings. 

If use gmail, there are some security features that have to be enabled/disabled
1 - Inside your gmail account go to Settings > Forwarding and POP/IMAP and enable the protocols(s) that you wish to use
2 - Enable access of less secure apps https://www.google.com/settings/security/lesssecureapps
	
* `messages_controller.rb`: Configure SMS sender.

Login [twilio](https://www.twilio.com/) account to get 'Account SID', 'Auth Token', 'Phone number', and modify
```rhtml
	TWILIO_ACCOUNT_SID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	TWILIO_AUTH_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	@client.messages.create(
		from: '+12345678912',
		...
	)
```
**[Sign up for free twilio trial account](https://www.twilio.com/try-twilio)**

## Setup

Create database tables
```
rake db:migrate
```

## Run

###1.Launch thin server

```
rackup private_pub.ru -s thin -E production
```

###2.Launch rails server on different terminal

```
rails s
```

## Done

Now open this URL in your browser, and sign in/sign up.

```
http://localhost:3000/
```
