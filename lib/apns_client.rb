class ApnsClient
  def self.sendmessage senderuserid, targetuserid, messagetype
    targetuser = User.find(targetuserid)
    
    if (targetuser.nil?)
      return
    end

    device_token = targetuser.apn_device_token
    if (device_token.nil?)
      return
    end

    if (messagetype == 1) || (messagetype == 2)
      senderuser = User.find(senderuserid)
      if (senderuser.nil?)
        return
      end
      badgecount = Connection.select("id").where("connections_id=#{connid} AND friend_state=1", connid: targetuserid).size

      if (messagetype == 1)       # 1: new friend request
        alertstr = "@%s has invited you to be a friend in Flux!" % [senderuser.username]
      else                        # 2: friend request accepted
        alertstr = "@%s is now your friend in Flux!" % [senderuser.username]
      end

      packet = {alert: alertstr, badge: badgecount, sound: "default"}
      APNS.send_notification(device_token, aps: packet)
      
    elsif (messagetype == 3)      # 3: clear badge (no alert, no message)
      packet = {badge: 0}
      APNS.send_notification(device_token, aps: packet)
      
    end    
  end
end