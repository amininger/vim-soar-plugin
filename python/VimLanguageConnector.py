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
