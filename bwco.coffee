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
    Template.existingCards.helpers
        cards: ->
            cardCollection = Cards.find().fetch().slice(-5).reverse();
            i.image = Images.find({_id: i.imageId}).fetch()[0] for i in cardCollection
            console.log(cardCollection);
            return cardCollection;



    Template.cardInput.events
        "click #submitCard": ->
            Cards.insert(
                name: $("#cardName").val(),
                rules: $("#cardRules").val(),
                unicode: $("#cardUnicode").val()
                cost: $("#cardCost").val()
                imageId: $("#cardImageId").val()
            )
            $("#cardName").val("");
            $("#cardRules").val("");
            $("#cardUnicode").val("");              
            $("#cardCost").val("");     
            $("#cardImage").val("");      
            $("#cardImageId").val("")

        "change #cardImage": (event, template) ->
            FS.Utility.eachFile(event, (file) ->
                Images.insert(file, (err, fileObj) ->
                    $("#cardImageId").val(fileObj._id)
                )
            )

    Template.allImages.helpers
        "images": ->
            return Images.find({})

if (Meteor.isServer)
    Images.allow({
        'insert': ->
            return true;
    });