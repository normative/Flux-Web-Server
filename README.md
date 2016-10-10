# Flux

## What is Flux?

Imagine going back to the street you grew up on and experiencing through photos how it has changed over time. Flux was created to do just that.

Flux technology was derived from military Wide Area Persistent Surveillance systems which quickly and accurately fuse large imagery data sets from multiple sources into composite images of large geographic areas.

Flux is an iOS app that is both a photo taker and viewer. Every photo can be annotated and users can take several photos at a time, upload it all to Flux, follow other people, and filter by location, tag or user. Using Flux, people can stand in their favourite places and virtually travel through time, experiencing the space in a completely new way. The result is an impressive new layer of cultural geography, a new kind of memory made possible by people taking photographs of places all over the world.

***

### How to Run

Running Flux is as simple as downloading the Flux app from the App Store on your iOS device and creating a free account. Explore the world around you through images taken by yourself or other users.

***

### Developing with Flux

Flux is available as an open source github library, comprising of the backend ( Ruby on Rails / Postgres ) and a front-end client ( iOS application ).  Both are available for free via github.com

#### Running the Webserver

1. Download the github repo [from github](https://github.com/normative/Flux-Web-Server)
2. Install [Docker](https://www.docker.com/) && Docker Compose

From a terminal:

1. Go to the project directory

   ``` 
   $ cd ~/Flux-Web-Server
   ```


2. Run Docker compose

   ```
   $ docker-compose up
   ```

3. Load the database

   1. Grab the webserver Container ID

      ```
      $ docker ps //get the container id for Image 'fluxwebserver_flux'
      ```

      2. Create the database

      ```
      $ docker exec -it CONTAINER_ID bundle exec rake db:setup
      ```

      3. Load Stored Procedures:  Stored procedures are saved in the *dbProcs/* directory. Open each file, and copy the contents of each command.

         ```
         $ docker ps //get the container id for Image 'postgres'
         ```

         Connect to the database server

         ```
         $ docker exec -it CONTAINER_ID bash
         ```

         Now, connect to the flux database

         ```
         $ psql -U postgres
         ```

         ```
         $ \c flux
         ```

         Paste the stored procedures into the command line to load.

4. Visit *localhost:3101* , and you should see a Rails welcome message.  Your backend server is up and running!

   ​

#### Running the iOS App locally

1. Download the github repo [from github](https://github.com/normative/Flux-iOS-App)

2. Open the project in Xcode.

3. Open the networking file ( https://github.com/normative/Flux-iOS-App/blob/master/SMLRcam/SMLRcam/FluxNetworkServices.m )

4. Update line #23

   ```
   define _AWSProductionServerURL  @"http://localhost:3103/"
   ```

   ```
   define _AWSSecureProductionServerURL  @"https://localhost:3101/"
   ```

5. Build the Xcode project on a device connected to the same network as your backend application and your good to go.

