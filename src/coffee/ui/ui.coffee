###
## Ui handles all things UI such as the menus, the notification popups,
## the editor panel, the big flashing cursor, the stats widget...
###

$ = require '../../js/jquery'
window.$ = $
window.jQuery = $
require '../../js/jquery.sooperfish'
require '../../js/jquery.easing-sooper'
require '../../js/jquery.simplemodal'

programs = require '../programs/programs'

class Ui

  constructor: (eventRouter, stats) ->
    # Setup Event Listeners
    eventRouter.addListener(
      "report-runtime-or-compile-time-error",
      (e) => @checkErrorAndReport(e)
    )
    eventRouter.addListener("clear-error", => @clearError() )
    eventRouter.addListener("autocoder-button-pressed", (state) ->
      if state is true
        $("#autocodeIndicator span").html("Autocode: on").css(
          "background-color", "#FF0000"
        )
      else
        $("#autocodeIndicator span").html("Autocode").css(
          "background-color", ""
        )
    )

    eventRouter.addListener("autocoderbutton-flash", ->
      $("#autocodeIndicator").fadeOut(100).fadeIn 100
    )

    eventRouter.addListener("auto-hide-code-button-pressed",
      (autoDimmingIsOn) ->
        if autoDimmingIsOn
          $("#dimCodeButton span").html("Hide Code: on")
        else
          $("#dimCodeButton span").html("Hide Code: off")
    )

    allDemos = programs.demos

    # Create an object with a property for each submenu.
    # That property contains an array with all the demos that belong to
    # that submenu.
    demoSubmenus = {}
    for demo of allDemos
      submenuOfThisDemo = allDemos[demo].submenu
      demoSubmenus[submenuOfThisDemo] ?= []
      demoSubmenus[submenuOfThisDemo].push(demo)

    for demoSubmenu of demoSubmenus

      demoSubmenuNoSpaces = demoSubmenu.replace(" ","_")
      # insert the submenu in the first level
      $("<li></li>").appendTo(
        $('#ulForDemos')
      ).attr('id', 'hookforDemos' + demoSubmenuNoSpaces)

      $("<span>#{demoSubmenu}</span>").appendTo(
        $('#hookforDemos' + demoSubmenuNoSpaces)
      )
      $("<ul id='#{demoSubmenuNoSpaces}'></ul>").appendTo(
        $('#hookforDemos' + demoSubmenuNoSpaces)
      )
      # now take each demo that belongs to this submenu and put it there
      for demo in demoSubmenus[demoSubmenu]
        a = """<li>
               <a id='#{demo}'>
               #{programs.demos[demo].title}
               </a>
               </li>"""
        $(a).appendTo(
          $('#'+demoSubmenuNoSpaces)
        )

    allTutorials = programs.tutorials

    # Create an object with a property for each submenu.
    # That property contains an array with all the tutorials that belong to
    # that submenu.
    tutorialSubmenus = {}
    for tutorial of allTutorials
      submenuOfThisTutorial = allTutorials[tutorial].submenu
      # create array if it didn't exist
      tutorialSubmenus[submenuOfThisTutorial] ?= []
      tutorialSubmenus[submenuOfThisTutorial].push(tutorial)

    for tutorialSubmenu of tutorialSubmenus

      tutorialSubmenuNoSpaces = tutorialSubmenu.replace(" ","_")
      # insert the submenu in the first level
      $("<li></li>").appendTo(
        $('#ulForTutorials')
      ).attr('id', 'hookforTutorials' + tutorialSubmenuNoSpaces)

      $("<span>#{tutorialSubmenu}</span>").appendTo(
        $('#hookforTutorials' + tutorialSubmenuNoSpaces)
      )
      $("<ul id='#{tutorialSubmenuNoSpaces}'></ul>").appendTo(
        $('#hookforTutorials' + tutorialSubmenuNoSpaces)
      )
      # now take each tutorial that belongs to this submenu and put it there
      for tutorial in tutorialSubmenus[tutorialSubmenu]
        a = """<li>
               <a id='#{tutorial}'>
               #{programs.tutorials[tutorial].title}
               </a>
               </li>"""
        $(a).appendTo(
          $('#'+tutorialSubmenuNoSpaces)
        )

    # Now that all the menu items are in place in the DOM,
    # invoke sooperfish,
    # which does some more transformations of its own.
    $('ul.sf-menu').sooperfish()

    $('#logo span').click(
      () ->
        $("#aboutWindow").modal()
        $("#simplemodal-container").height 250
        false
    )

    $("#demos ul li a").click ->
      eventRouter.emit("load-program", $(@).attr("id"))
      false

    $("#tutorials li a").click ->
      eventRouter.emit("load-program", $(@).attr("id"))
      false

    $("#languages li a").click ->
      eventRouter.emit("set-language", $(@).attr("id"))
      false

    $("#autocodeIndicator").click(
      () ->
        eventRouter.emit("toggle-autocoder")
        false
    )

    $("#dimCodeButton").click(
      () ->
        eventRouter.emit("editor-toggle-dim")
        false
    )

    $('#resetButton').click(
      () ->
        eventRouter.emit("reset")
        $(@).stop().fadeOut(100).fadeIn 100
        false
    )

    $("#startingCurtainScreen").fadeOut()
    $("#formCode").css "opacity", 0


  checkErrorAndReport: (e) ->
    $("#errorMessageDisplay").css "color", "red"

    # if the object is an exception then get the message
    # otherwise e should just be a string
    errorMessage = e.message or e
    if errorMessage.indexOf("Unexpected 'INDENT'") > -1
      errorMessage = "weird indentation"
    else if errorMessage.indexOf("Unexpected 'TERMINATOR'") > -1
      errorMessage = "line not complete"
    else if errorMessage.indexOf("Unexpected 'CALL_END'") > -1
      errorMessage = "line not complete"
    else if errorMessage.indexOf("Unexpected '}'") > -1
      errorMessage = "something wrong"
    else if errorMessage.indexOf("Unexpected 'MATH'") > -1
      errorMessage = "weird arithmetic there"
    else if errorMessage.indexOf("Unexpected 'LOGIC'") > -1
      errorMessage = "odd expression thingy"
    else if errorMessage.indexOf("Unexpected 'NUMBER'") > -1
      errorMessage = "lost number?"
    else if errorMessage.indexOf("Unexpected 'NUMBER'") > -1
      errorMessage = "lost number?"
    else
      errorMessage = errorMessage.replace(/ReferenceError:\s/g, "") if(
        errorMessage.indexOf("ReferenceError") > -1
      )
    $("#errorMessageDisplay").text errorMessage

  clearError: ->
    $("#errorMessageDisplay").css "color", "#000000"
    $("#errorMessageDisplay").text ""

  soundSystemOk: ->
    $("#soundSystemStatus").text("Sound System On").removeClass("off")

module.exports = Ui

