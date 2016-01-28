$ = require('jquery')

test "show selected packet", (assert) ->
  dripcap.action.emit 'core:start-sessions'
  assert.wait('[riot-tag=session-dialog] .modal:visible')
  .then -> assert.click('[riot-tag=session-dialog] [name=start]')
  .then -> assert.wait -> $('[riot-tag=packet-list-view] tr:not(.head)').length > 0
  .then -> assert.click('[riot-tag=packet-list-view] tr:not(.head):first')
  .then -> assert.wait -> $('[riot-tag=packet-view] packet-view-item').length == 47