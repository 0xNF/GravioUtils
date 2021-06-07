import os, sys, sqlite3, argparse, re
from datetime import datetime, timedelta
import statistics
import glob

pattern_action_start = r'\[(.+?)\].*\[(.+?)\] Starting Action: (.+?)$'
pattern_action_end = r'\[(.+?)\].*\[(.+?)\] Action Ended'
date_format =  "%Y-%m-%d %H:%M:%S.%f"
n_digits = 3
padding = 20

class Execution:
    def __init__(self, eid, aname, stime):
        self.actionName = aname
        self.executionId = eid
        self.startTime = stime
        self.endTime = 0
        self.delta = timedelta.min

    def __str__(self):
        return f"({self.executionId}) {self.actionName} : {self.delta}"


class ExecutionStats:
    def __init__(self, aname, mean, median, mode, stddev, minT, maxT, count):
        self.actionName = aname
        self.count = count
        self.mean = mean
        self.median = median
        self.mode = mode
        self.stddev = stddev
        self.min = minT
        self.max = maxT
        
    def format(self, fmt="txt"):
        if (fmt == "txt"):
            l = [self._adjust(x, pad=True) for x in [self.count, self.mean, self.median, self.mode, self.min, self.max, self.stddev]]
            l.insert(0, (self.actionName[:min(len(self.actionName), padding)]).ljust(padding))
            s = " ".join(l)
            return s
        else:
            l = [self._adjust(x, pad=False) for x in [self.count, self.mean, self.median, self.mode, self.min, self.max, self.stddev]]
            l.insert(0, self.actionName)
            return ",".join(l)

    def _adjust(self, num, pad=True):
        n = round(num, n_digits)
        if pad:
            return f"{n}".ljust(padding)
        else:
            return f"{n}"

def parseLine(i, line, executions, executions_by_name):
    actionStartMatch = re.search(pattern_action_start, line)
    if actionStartMatch is None:
        actionEndMatch = re.search(pattern_action_end, line)
        if actionEndMatch is None:
            return -1
        else:
            g = actionEndMatch.groups()
            endTime = g[0]
            endTimeParsed = None
            try:
                endTimeParsed = datetime.strptime(endTime, date_format)
            except:
                print(f"Skipping line {i}, date format was invalid")
                return -1
            eid = g[1]
            try:
                e = executions[eid]
                e.endTime = endTimeParsed
                e.delta = (e.endTime - e.startTime)
            except KeyError as k:
                print(f"An invalid key was specified while searching for an execution using line {i}")
                return -1
    else:
        g = actionStartMatch.groups()
        startTime = g[0]
        startTimeParsed = None
        try:
            startTimeParsed = datetime.strptime(startTime, date_format)
        except:
            print(f"Skipping line {i}, date format was invalid")
            return -1
        eid = g[1]
        aname = g[2]
        e = Execution(eid, aname, startTimeParsed)
        executions[eid] = e
        l = executions_by_name.get(aname)
        if l is None:
            executions_by_name[aname]  = [e]
        else:
            executions_by_name[aname].append(e)
    return 0

def groupBy(execs):
    estats = {}
    for key in execs:
        emap = [x.delta.total_seconds() * 1000 for x in execs[key]]
        minTime = min(emap)
        maxTime = max(emap)
        mean = statistics.mean(emap)
        median = statistics.median(emap)
        mode = statistics.mode(emap)
        stddev = 0 if len(emap) == 1 else statistics.stdev(emap)
        es = ExecutionStats(key, mean, median, mode, stddev, minTime, maxTime, len(emap))
        estats[key] = es
    return estats


def analyze(lines):
    executions = {}
    executions_by_name = {}
    for idx, line in enumerate(lines):
        parseLine(idx, line, executions, executions_by_name)
    return groupBy(executions_by_name)

def output(executionStats, fmt="txt"):
    headers = ["Action Name (ms)", "Count", "Mean", "Median", "Mode", "Min", "Max", "Standard Dev"]
    if fmt == "txt":
        s = " ".join([x.ljust(padding) for x in headers])
    else:
        s = ",".join(headers)
    print(s)
    keys = executionStats.keys()
    for key in sorted(keys):
        print(executionStats[key].format(fmt))
    return


def mergeDs(source, dest):
    for key in source:
        if dest.get(key) == None:
            dest[key] = source[key]
        else:
            dest[key].extend(source[key])


def main():
    parser = argparse.ArgumentParser(description='Show execution stats of Gravio Actions fro a supplied Action Log')
    parser.add_argument("fmt", help="[txt, csv]")
    parser.add_argument('actionlogs', help='Gravio Action Log file or folder of files to analyze')
    args = parser.parse_args()
    try:
        fmt = "txt" if args.fmt is None else args.fmt
        lines = []
        files = glob.iglob(args.actionlogs)
        mainStats = {}
        for fstar in files:
            with open(fstar, mode='r') as f:
                _lines = f.readlines()
                if (len(_lines) == 0):
                    continue
                lines.extend(_lines)
        mainStats = analyze(lines)
        output(mainStats, fmt)
        return 0
    except FileNotFoundError as fnf:
        print("File not found")
        return -1
    except Exception as e:
        print(e)
        return -2

if __name__ == "__main__":
    sys.exit(main())