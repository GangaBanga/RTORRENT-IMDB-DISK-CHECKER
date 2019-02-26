<< 'COMMENT'

Manual Setup Instructions:

1. Make the scripts executable by pasting the following command in your terminal:

chmod +x checker.py config.py remotecall.py

2. rtorrent.rc File Modification

2a. Locate your rtorrent.rc file via this command:

find /home/$USER -name '.rtorrent.rc'

2b. Add the following code to your rtorrent.rc file !! Update the path to checker.py !! Restart rtorrent once added:

Python 2:
method.set_key = event.download.inserted_new,checker,"execute=python,/path/to/checker.py,$d.name=,$d.custom1=,$d.size_bytes=,$d.hash="

Python 3:
method.set_key = event.download.inserted_new,checker,"execute=python3,/path/to/checker.py,$d.name=,$d.custom1=,$d.size_bytes=,$d.hash="

3. SCGI Address Addition

3a. Enter the following command in your terminal to obtain your SCGI address/port:

find /home/$USER -name '.rtorrent.rc' | xargs grep -oP "^[^#]*scgi.* = \K.*"

3b. Update the scgi variable in line 9 of config.py with your own SCGI address/port.

4. Python Module Installations Required for IMDB Function (Skip if Unused)

4a. Enter the following commands in your terminal to install parse-torrent-name and ImdbPie:

pip install parse-torrent-name
pip install imdbpie

COMMENT

chmod +x checker.py config.py remotecall.py

rtorrent=$(find /home/$USER -name '.rtorrent.rc')

if [ -z "$rtorrent" ]; then
    echo 'rtorrent.rc file not found. Terminating script.'
    exit
fi

printf '\nDo you want the script to be run in Python 2 or 3? Python 3 is faster.

Enter 2 for Python 2 or 3 for Python 3.\n'

while true; do
    read answer
    case $answer in

        [2] )
                 version='python2'
                 break
                 ;;

        [3] )
                 version='python3'
                 break
                 ;;

        * )
              echo 'Enter 2 or 3'
              ;;
    esac
done

sed -i "1i\
method.set_key = event.download.inserted_new,checker,\"execute=$version,$PWD/checker.py,\$d.name=,\$d.custom1=,\$d.size_bytes=,\$d.hash=\"" "$rtorrent"

printf '\nWill you be using the IMDB function of the script (Y/N)?\n'

while true; do
    read answer
    case $answer in

        [yY] )
                 pip install imdbpie -q || sudo pip install imdbpie -q || printf '\nFailed to install Python module: imdbpie\n\n'
                 pip install parse-torrent-name -q || sudo pip install parse-torrent-name -q || printf '\nFailed to install Python module: parse-torrent-name\n'
                 break
                 ;;

        [nN] )
                 break
                 ;;

        * )
              echo 'Enter y or n'
              ;;
    esac
done

scgi=$(find /home/$USER -name '.rtorrent.rc' | xargs grep -oP "^[^#]*scgi.* = \K.*")

if [ -z "$scgi" ]; then
    printf '\nSCGI address not found. Locate it in your rtorrent.rc file and manually update it in the config.py file.\n'
else
    sed -i "9s~.*~scgi = \"$scgi\"~" config.py
fi

printf '\nRestart rtorrent for the changes to take effect.\n\n'
printf  'Configuration completed.\n\n'
