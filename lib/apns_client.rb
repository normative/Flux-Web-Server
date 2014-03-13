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

#    badgecount = Connection.select("id").where("connections_id=:connid AND friend_state=1", connid: targetuserid).size
    badgecount = 0
    if (messagetype == 1) ||      # 1: new friend request
       (messagetype == 2) ||      # 2: friend request accepted
       (messagetype == 3)         # 3: following notification
      senderuser = User.find(senderuserid)
      if (senderuser.nil?)
        return
      end

      if (messagetype == 1)
        alertstr = "@%s sent you a friend request!" % [senderuser.username]
      elsif (messagetype == 2)                        
        alertstr = "@%s is now your friend!" % [senderuser.username]
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