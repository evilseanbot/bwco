Cards = new Mongo.Collection("cards")

if (Meteor.isClient) 
    Template.existingCards.helpers
        cards: ->
            return Cards.find().fetch().slice(-5).reverse()

    Template.cardInput.events
        "click #submitCard": ->
            Cards.insert(
                name: $("#cardName").val(),
                rules: $("#cardRules").val(),
                unicode: $("#cardUnicode").val()
                cost: $("#cardCost").val()              
            )
            $("#cardName").val("");
            $("#cardRules").val("");
            $("#cardUnicode").val("");              
            $("#cardCost").val("");              

