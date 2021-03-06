class ApnsClient
  def self.sendmessage senderuserid, targetuserid, messagetype
    targetuser = User.find(targetuserid)
   
    if (targetuser.nil?)
      return
    end

    device_token = targetuser.apns_device_token
    if (device_token.nil?) || (device_token.size != 64)
      return
    end

    badgecount = 0
    if (messagetype == 1) ||      # 1: new follower request
       (messagetype == 2)       # 2: follower request accepted
#       (messagetype == 3)         # 3: following notification
      senderuser = User.find(senderuserid)
      if (senderuser.nil?)
        return
      end

      if (messagetype == 1)
        alertstr = "@%s sent you a follower request!" % [senderuser.username]
        badgecount = Connection.select("id").where("connections_id=:connid AND following_state=1", connid: targetuserid).size
      elsif (messagetype == 2)                        
        alertstr = "You are now following @%s!" % [senderuser.username]
      elsif (messagetype == 3)                        
        alertstr = "@%s is following you!" % [senderuser.username]
      end

      packet = {alert: alertstr, badge: badgecount, sound: "default"}
      APNS.send_notification(device_token, aps: packet, details: {messagetype: messagetype, sender: senderuserid})
      
    elsif (messagetype == 10) ||   # 10: clear badge (no alert, no message)
          (messagetype == 11)      # 11: update badge (no alert, no message)
      
      if (messagetype == 10)
        badgecount = 0
      end
      
      packet = {badge: badgecount}
      APNS.send_notification(device_token, aps: packet, details: {messagetype: messagetype})
      
    end    
  end
end
