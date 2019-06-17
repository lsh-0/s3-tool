"takes a subset of last-listing and copies it to a new bucket. good for bulk-loading files to a test bucket"

from pprint import pprint
import os, sys,re

def parse(lines):
    struct = {'upload:': [], 'in:': [], 'to:': []}
    key = None
    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line in struct:
            key = line
            continue
        struct[key].append(line)
    struct['in:'] = struct['in:'][0]
    struct['to:'] = struct['to:'][0].rstrip('/')
    struct['upload:'] = list(map(lambda l: l.split()[-1], struct['upload:']))
    return struct

def upload(struct):
    for line in struct['upload:']:
        # ./s3.sh   copy_between_buckets   elife-ejp-ftp/ejp_query_tool_query_id_780_DataScience:_Reviewer_info_-_last_week_2019_06_16_eLife.csv     staging-elife-data-pipeline/flows/ejp-csv-deposit/test/ejp_query_tool_query_id_780_DataScience:_Reviewer_info_-_last_week_2019_06_16_eLife.csv

        # rename the destination file
        #dest = re.sub('_\d{3,4}_', '_', line, 1) # removes the query ID
        
        cmd = "./s3.sh copy_between_buckets %s/%s %s/%s" % (struct['in:'], line, struct['to:'], dest)
        print(cmd)
        os.system(cmd)
    return struct

def main(args):
    return upload(parse(open(args[0], 'r').readlines()))

if __name__ == '__main__':
    pprint(main(sys.argv[1:]))
