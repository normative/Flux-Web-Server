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
       (messagetype == 2)         # 2: friend request accepted
      senderuser = User.find(senderuserid)
      if (senderuser.nil?)
        return
      end

      if (messagetype == 1)
        alertstr = "@%s has invited you to be a friend in Flux!" % [senderuser.username]
      else                        
        alertstr = "@%s is now your friend in Flux!" % [senderuser.username]
      end

      packet = {alert: alertstr, badge: badgecount, sound: "default"}
      APNS.send_notification(device_token, aps: packet, messagetype: messagetype)
      
    elsif (messagetype == 3) ||   # 3: clear badge (no alert, no message)
          (messagetype == 4)      # 4: update badge (no alert, no message)
      
      if (messagetype == 3)
        badgecount = 0
      end
      
      packet = {badge: badgecount}
      APNS.send_notification(device_token, aps: packet, messagetype: messagetype)
      
    end    
  end
end