GpgAtomView = require './gpg-atom-view'
{CompositeDisposable} = require 'atom'
{BufferedProcess} = require 'atom'

module.exports = GpgAtom =
  gpgAtomView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'gpg-atom:decrypt': => @decrypt()
    @subscriptions.add atom.commands.add 'atom-workspace', 'gpg-atom:encrypt': => @encrypt()

  decrypt: ->
    editor = atom.workspace.getActiveTextEditor()
    @runGpgDecrypt(editor)

  encrypt: ->
    editor = atom.workspace.getActiveTextEditor()
    @runGpgEncrypt(editor, 'Martin Stoffel')

  runGpgEncrypt: (editor, name) ->
    fileName = editor.getPath()
    command = 'gpg'
    args = ['-q', '--batch', '-a', '-e', '-u', name, '-r', name, '-o', '-', fileName]
    stdout = (output) -> editor.setText(output)
    exit = (code) -> console.log("gpg error: #{code}")
    process = new BufferedProcess({command, args, stdout, exit})

  runGpgDecrypt: (editor) ->
    fileName = editor.getPath()
    command = 'gpg'
    args = ['-d', '-q', fileName]
    stdout = (output) -> editor.setText(output)
    exit = (code) -> console.log("gpg error: #{code}")
    process = new BufferedProcess({command, args, stdout, exit})


  deactivate: ->
    @subscriptions.dispose()
