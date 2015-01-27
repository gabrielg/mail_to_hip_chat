          _
         [_|                      .    .        .               .       .  
     .-----|--,       ,-,-. ,-. . |    |- ,-.   |-. . ,-.   ,-. |-. ,-. |- 
    /      | /_\_     | | | ,-| | |    |  | |   | | | | |   |   | | ,-| |  
    |       |__.-|    ' ' ' `-^ ' `'---`' `-'---' ' ' |-'---`-' ' ' `-^ `' 
    |       |__\_|                                    |                    
    '---,-,-;---'                                     '                    
        | |
        
# Mail To HipChat

Mail To HipChat lets you wire up email notifications to [HipChat](http://hipchat.com/r/30ad1). This is useful in situations where a third-party service doesn't have a real [WebHook](http://www.webhooks.org/) available, but you still want to be able to dump notifications into HipChat. The [Airbrake](http://airbrake.io) exception notification service is one example.

## How It Works

Mail To HipChat is designed to be deployed on [Heroku](http://heroku.com) and used with the [CloudMailIn](http://cloudmailin.com/) add-on. Adding the CloudMailIn incoming email address to the recipients list of the service you wish to integrate with will shuffle emails off to your instance of this tool as a HTTP POST request. A list of mail handlers is checked, and the appropriate one is invoked to format a message and send it off to one or more HipChat rooms.

## Prerequisites

You will need an account on Heroku and admin access to your HipChat group. 

## Initial Setup

1. Make a home for your shiny new Mail To HipChat instance to live in.

        $ mkdir my-mail_to_hip_chat
        $ cd my-mail_to_hip_chat
        $ git init 
    
2. Do the bundler dance.

        $ echo 'source "http://rubygems.org"' >> Gemfile
        $ echo 'gem "mail_to_hip_chat"' >> Gemfile
        $ bundle install
        $ git add Gemfile Gemfile.lock
        $ git commit -m "Getting down with bundler"
    
3. Copy over the default config.ru.

        $ cp "`bundle show mail_to_hip_chat`/support/config.ru" .
        $ git add config.ru
        $ git commit -m "Adding default config.ru"

4. Set up a new Heroku application with CloudMailIn.
  
        $ heroku create --stack cedar
        $ heroku addons:add cloudmailin

5. Setup the CloudMailIn target address to point at your app.
    
    Get the target address for CloudMailIn to hit when it receives an email.
    
        $ echo "`heroku apps:info | grep "Web URL" | cut -c9- | tr -d ' ' | awk '{print $1"notifications/create"}'`"
    
    Get your CloudMailIn username and password from the Heroku app config.
    
        $ heroku config | grep CLOUDMAILIN

    [Log in to CloudMailIn](https://cloudmailin.com/users/sign_in) using the given `CLOUDMAILIN_USERNAME` and `CLOUDMAILIN_PASSWORD`. You'll see the entry for `CLOUDMAILIN_FORWARD_ADDRESS` in the list. Hit "Manage" and then "Edit Target", and set the target to the target address we retrieved above.
    
6. Get a HipChat API token and the ID for the Room(s) to send messages to.
  
    Visit your [HipChat API Admin page](http://hipchat.com/group_admin/api). If there's a token you want to already use, use that one. If not, create a new token of type "Notification". Once you have the token, set it as an environment variable on Heroku.
  
        $ heroku config:add HIPCHAT_API_TOKEN=fd3deeef7b88b95c1780e6237c41c30f

    Visit your [HipChat Chat History page](https://hipchat.com/history). The integer in the URL for the history of each room (for example, `https://gabe.hipchat.com/history/room/31373`) is the room ID. Once you have the ID(s) of the rooms you wish to send messages to, set it as a comma separated environment variable on Heroku.
  
        $ heroku config:add HIPCHAT_ROOMS=31373,31374

7. Deploy this sucker.

        $ git push heroku master
    
8. Get your CloudMailIn forwarding address and send a test email.

        $ heroku config | grep CLOUDMAILIN_FORWARD_ADDRESS
    
    Send an email to the `CLOUDMAILIN_FORWARD_ADDRESS`, with a subject of "Testing Setup". The message should appear in the rooms you've configured Mail To HipChat to send messages to.

## Hooking it up to Airbrake

Just add a new user to your project, set their email address to `CLOUDMAILIN_FORWARD_ADDRESS`, and watch the exceptions roll in. Then turn your face from God and weep in abject horror.

## Adding new message handlers

See the included Airbrake handler for an example. Really, any object that has a `call` method that takes one argument can be used.

## FAQ

* Can I use something besides CloudMailIn/Heroku?
  
    Most likely, yes. The code has only been tested using CloudMailIn and Heroku, but really, there's not that much tying it to that particular kind of setup, besides the CloudMailIn signature verification stuff in the Rack app.
    
* Could I say, feed it email using a `.forward` file?

    Probably. The only part dependent on actually being a web app is the Rack application itself.
    
* How do your projects end up with such rad ASCII art?

        $ figlist | xargs -I {} /bin/bash -c "figlet -f {} your_project_name"
        $ open "http://google.com/search?q=something_related_to_your_project+ascii+art"
        
## TODO

* There are too many steps for initial setup. This needs to be cut down.