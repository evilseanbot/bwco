Cards = new Mongo.Collection("cards")

Images = new FS.Collection("images", {
  stores: [new FS.Store.GridFS("images", {path: "~/uploads"})]
});  

Images.deny({
    insert: ->
        return false;
    , update: ->
        return false;
    , remove: ->
        return false;
    , download: ->
        return false;
});

Images.allow({
    insert: ->
        return true;
    ,
    update: ->
        return true;
    ,
    remove: ->
        return true;
    ,
    download: ->
        return true;
});

if (Meteor.isClient) 
    Meteor.subscribe("moreUserData");
    Template.newsFeed.helpers
        cards: ->
            cardCollection = Cards.find({approved: true}).fetch().slice(-5).reverse();
            i.image = Images.find({_id: i.imageId}).fetch()[0] for i in cardCollection
            return cardCollection;

    Template.tabs.helpers
        admin: ->
            user = Meteor.user();
            if(user)
                if (user.emails[0].address == "a@b.com")
                    return true
            return false     
        playersInLobby: ->
            return Meteor.users.find({"status.online": true}).fetch().length

    Template.cardInput.events
        "click #submitCard": ->
            Cards.insert(
                name: $("#cardName").val(),
                rules: $("#cardRules").val(),
                cost: $("#cardCost").val()
                imageId: $("#cardImageId").val()
                approved: true
            )
            $("#cardName").val("");
            $("#cardRules").val("");
            $("#cardCost").val("");     
            $("#cardImage").val("");      
            $("#cardImageId").val("")

        "change #cardImage": (event, template) ->
            FS.Utility.eachFile(event, (file) ->
                Images.insert(file, (err, fileObj) ->
                    $("#cardImageId").val(fileObj._id)
                )
            )       

    Template.admin.helpers
        "cards": ->
            cardCollection = Cards.find().fetch().reverse();
            i.image = Images.find({_id: i.imageId}).fetch()[0] for i in cardCollection
            return cardCollection;

    Template.admin.events
        "change #cardApproved": (event) ->
            Cards.update({_id: this._id}, {$set: {approved: event.target.checked}})

    Template.playGame.helpers
        "joinedLobby": ->
            return Session.get("joinedLobby");
        "players": ->
            return Meteor.users.find({"status.online": true})
        "twoOrMorePlayers": ->
            return Meteor.users.find({"status.online": true}).fetch().length > 1

    Template.playGame.events
        "click #joinLobby": ->
            Players.insert(
                name: $("#playerName").val()
            )
            Session.set("joinedLobby", true)

    Accounts.ui.config({
        passwordSignupFields: "USERNAME_AND_OPTIONAL_EMAIL"
    });

if (Meteor.isServer)
    Images.allow({
        'insert': ->
            return true;
    });

    Meteor.publish("moreUserData", ->
        return Meteor.users.find({}, {fields: {'status': 1, 'username': 1}});
    )