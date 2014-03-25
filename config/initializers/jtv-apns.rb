###################
# Hosts Config
###################

# Push Notification Service:
#
# (default: gateway.sandbox.push.apple.com is)
# Set as below for a production install
# APNS.host = 'gateway.push.apple.com' 

# (default: 2195)
# APNS.port = 2195

# Feedback Service:
#
# (default: feedback.sandbox.push.apple.com)
# APNS.feedback_host = 'feedback.push.apple.com'

# (default: 2196)
# APNS.feedback_port = 2196

####################
# Certificate Setup
####################

# Path to the .pem file created earlier
# APNS.pem  = '/home/denis/workspace/SMLR_server/SMLR_webserver/config/certs/apn_development.pem'

# Password for decrypting the .pem file, if one was used
# APNS.pass = 'xxxx'

####################
# Connection Mgmt
####################

# Cache open connections when sending push notifications
# this will force the gem to keep 1 connection open per
# host/port pair, and reuse it when sending notifications

# (default: false)
APNS.cache_connections = true
