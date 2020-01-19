#!/usr/bin/env bash

set -euxo pipefail

TIMEOUT=/usr/local/Cellar/coreutils/*/bin/timeout


cd thumbs

curl https://www.pornhub.com/categories |
    pup '#categoriesListSection > li.cat_pic.alpha > div > a json{}' |
    jq 'map(.alt + "§" + .href)' |
    grep --only-matching '[^"]*§[^"]*' |
    shuf |
    (
        IFS=$'\n'
        while read category;
        do
            name=$(echo $category | cut -d § -f 1 | sed s:/:-:g)
            href=$(echo $category | cut -d § -f 2-)
            if echo $href | grep -q -F '?'
            then 
                href="${href}&page=1"
            else
                href="${href}?page=1"
            fi

            if [ -f $name/more-info.txt ]
            then
                continue
            fi

            mkdir -p $name
            (
                cd $name
                # $TIMEOUT 60 youtube-dl \
                #     --get-thumbnail \
                #     --skip-download \
                #     "https://www.pornhub.com${href}" > thumbs.urls
                # wget --input-file thumbs.urls
                curl "https://www.pornhub.com${href}" |
                    pup 'div.phimage > div.img.fade.videoPreviewBg.fadeUp > a json{}' |
                    jq 'map(
                        .href +
                        "§" +
                        .children[0]."data-thumb_url" +
                        "§" +
                        .children[0]."data-thumbs"
                    )' |
                    grep --only-matching '[^"]*§[^"]*' > more-info.txt
            )
        done;
    )

# clean up empty files
# wc -l */thumbs.urls |
#     sort -g |
#     head -n 10 |
#     grep '^ *[ 12][0-9] ' |
#     sed 's/^ *[ 12][0-9] //' |
#     (
#         ret=0
#         IFS=$'\n'
#         while read file;
#         do
#             mv "$file" "$file-$(date +%s)"
#             ret=1
#         done
#         exit $ret
#     )
