class @Houston.Releases.ChangesView extends Houston.NestedResources
  resource: 'changes'
  viewPath: 'houston/releases/changes'

  events:
    'keypress .change-description input': 'onKeyPress'
    'keyup .change-description input': 'onKeyUp'

  initialize: (options)->
    @collection = new Houston.Releases.Changes(options.values, parse: true)
    super
    @options = options
    @templateOptions.tags = @options.tags

  onKeyPress: (e)->
    if e.keyCode == 13
      e.preventDefault()
      e.stopImmediatePropagation()
      @addResource()
      $(e.target).closest('.nested-row').next().find('input').select()

  onKeyUp: (e)->
    if e.keyCode == 8 and $(e.target).val() == ''
      e.preventDefault()
      e.stopImmediatePropagation()
      $(e.target).closest('.nested-row').prev().find('input').select()
      $(e.target).closest('.nested-row').remove() # <-- is this a good idea?
    if e.keyCode == 38
      $(e.target).closest('.nested-row').prev().find('input').select()
    if e.keyCode == 40
      $(e.target).closest('.nested-row').next().find('input').select()
