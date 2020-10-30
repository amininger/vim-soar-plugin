import vim

def insert_text_at_cursor(text, scroll=True):
    """ Will insert the given text at the cursor and scroll to the end (if scroll==True) """
    lines = text.split("\n")
    win = vim.current.window
    win.buffer.append(lines, win.cursor[0])
    if scroll:
        win.cursor = (win.cursor[0] + len(lines), 0)

def print_id(agent, soar_id, depth=1):
    """ Will return the printout of the given id to the given depth """
    return agent.execute_command("p " + soar_id + " -d " + str(depth))

def get_current_substate(agent):
    """ Returns the identifier symbol of the deepest state for the given SoarAgent
        (Prints the stack and gets the bottom state)"""
    stack = agent.execute_command("p --stack").split("\n")
    # Find the last line in the stack printout that matches '  :      ==>S: S124 (impasse-type)'
    for line in reversed(stack):
        words = line.split()
        if len(words) >= 3 and words[1] == '==>S:':
            return words[2]
    return "S1"

def get_current_operator(agent):
    """ Returns the symbol of the currently selected operator on the deepest state for the given SoarAgent
        (Prints the stack and gets the bottom operator) """
    stack = agent.execute_command("p --stack").split("\n")
    # Find the last line in the stack printout that matches '  :        O: O452 (operator-name)'
    for line in reversed(stack):
        words = line.split()
        if len(words) >= 3 and words[1] == 'O:':
            return words[2]
    return ""

def get_filtered_rules(agent, pattern):
    """ Returns a printout of all rules that contain the given pattern """
    all_rules = agent.execute_command("p").split("\n")
    return "".join(agent.execute_command("p " + rule_name) for rule_name in all_rules 
            if pattern in rule_name)

def get_filtered_chunks(agent, pattern):
    """ Returns a printout of all chunks that match the given pattern """
    all_chunks = agent.execute_command("pc").split("\n")
    return "".join(agent.execute_command("p " + chunk_name) for chunk_name in all_chunks
            if pattern in chunk_name)

def excise_rules_matching_pattern(agent, pattern):
    all_rules = agent.execute_command("p").split("\n")
    for rule_name in all_rules:
        if pattern in rule_name:
            agent.execute_command("excise " + rule_name, print_res=True)

def write_fired_rules(agent, filename):
    """ Writes out all rules that have fired so far into a single file """
    firing_counts = agent.execute_command("fc").split("\n")
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
            f.write(agent.execute_command("p " + rule_name))
