import vim

def insert_text_at_cursor(text, scroll=True):
    """ Will insert the given text at the cursor and scroll to the end (if scroll==True) """
    lines = text.split("\n")
    win = vim.current.window
    win.buffer.append(lines, win.cursor[0])
    if scroll:
        win.cursor = (win.cursor[0] + len(lines), 0)

def parse_wm_printout(text):
    """ Given a printout of soar's working memory, parses it into a dictionary of wmes, 
        Where the keys are identifiers, and the values are lists of wme triples rooted at that id

    :param text: The output of a soar print command for working memory
    :type text: str

    :returns dict{ str, list[ (str, str, str) ] }

    """
    text = text.replace("\n", " ")
    text = text.replace(")", "") # Don't care about closing parentheses
    tokens = [ word.strip() for word in text.split() ]
    wmes = dict()
    cur_id = None
    cur_wmes = []
    i = 0

    while i < len(tokens):
        token = tokens[i]
        i += 1
        # Ignore operator preferences
        if token in [ '+', '>', '<', '!', '=' ]:
            continue
        # Beginning of new identifier section
        if token[0] == '(':
            cur_id = token[1:]
            cur_wmes = []
            wmes[cur_id] = cur_wmes
            continue
        # Expecting an attribute
        if token[0] != '^':
            print("UNEXPECTED TOKEN for " + cur_id + ": " + token)
            continue
        attr = token[1:]
        val = tokens[i]
        i += 1
        # Check for multi-word quoted strings surrounded by |
        if val[0] == '|':
            cur_word = val
            while cur_word[-1] != '|':
                cur_word = tokens[i]
                i += 1
                val += ' ' + cur_word
        cur_wmes.append( (cur_id, attr, val) )
    
    return wmes

def get_filtered_rules(agent, pattern):
    """ Returns a printout of all rules that match the given pattern """
    return_str = ""

    all_rules = agent.get_command_result("p").split("\n")
    for rule_name in all_rules:
        if pattern in rule_name:
            return_str += agent.get_command_result("p " + rule_name)

    return return_str

def get_filtered_chunks(agent, pattern):
    """ Returns a printout of all chunks that match the given pattern """
    return_str = ""

    all_chunks = agent.get_command_result("pc").split("\n")
    for chunk_name in all_chunks:
        if pattern in chunk_name:
            return_str += agent.get_command_result("p " + chunk_name)

    return return_str

def extract_fired_rules(agent, filename):
    """ Prints out all rules that have fired so far into a single file """
    firing_counts = agent.get_command_result("fc").split("\n")
    with open(filename, 'w') as f:
        for line in firing_counts:
            args = line.split()
            # Want lines of the form     N: production*name
            if len(args) < 2 or args[0][-1] != ':':
                continue
            count = int(args[0][:-1]) # strip colon
            if count == 0:
                continue
            rule_name = args[1]
            f.write(agent.get_command_result("p " + rule_name))
