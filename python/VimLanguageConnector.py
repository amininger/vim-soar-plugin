""" Used by the Rosie Agent to display the chat history in the vim debugger """
import sys
import vim

from string import digits

from pysoarlib import LanguageConnector
from VimWriter import VimWriter

class VimLanguageConnector(LanguageConnector):
    def __init__(self, agent, vim_writer):
        LanguageConnector.__init__(self, agent, lambda message: vim_writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True))

        self.rosie_message_callback = lambda message: vim_writer.write(message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True)
        self.register_message_callback(self.rosie_message_callback)
        self.add_output_command("scripted-sentence")

    def on_output_event(self, command_name, root_id):
        if command_name == "scripted-sentence":
            self.process_scripted_sentence(root_id)
        else:
            super().on_output_event(command_name, root_id)

    def process_scripted_sentence(self, root_id):
        sentence = root_id.GetChildString("sentence")
        self.rosie_message_callback(sentence)
        root_id.CreateStringWME("handled", "true")
