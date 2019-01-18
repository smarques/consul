App.Forms =

  disableEnter: ->
    $('form.js-enter-disabled').on('keyup keypress', (event) ->
      if event.which == 13
        e.preventDefault()
    )

  submitOnChange: ->
    $('.js-submit-on-change').unbind('change').on('change', ->
      $(this).closest('form').submit()
      false
    )

  toggleLink: ->
    $('.js-toggle-link').unbind('click').on('click', ->
      $($(this).data('toggle-selector')).toggle("down")
      if $(this).data('toggle-text') isnt undefined
        toggle_txt = $(this).text()
        $(this).text( $(this).data('toggle-text')  )
        $(this).data('toggle-text', toggle_txt)

      false
    )

  synchronizeInputs: ->
    $("[name='progress_bar[percentage]']").on
      input: ->
        $("[name='#{this.name}']").val($(this).val())

  hideOrShowFieldsAfterSelection: ->
    $("[name='progress_bar[kind]']").on
      change: ->
        title_field = $("[name^='progress_bar'][name$='[title]']").parent()

        if this.value == "primary"
          title_field.addClass("hide")
        else
          title_field.removeClass("hide")

    $("[name='progress_bar[kind]']").change()

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    App.Forms.synchronizeInputs()
    App.Forms.hideOrShowFieldsAfterSelection()
    false
