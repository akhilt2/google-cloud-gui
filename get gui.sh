#!/bin/bash
if [ $# -eq 0 ]; then
env=xfce
elif [ $# -eq 1 ]; then
case $1 in -h|--help)
echo "Usage: $0 [OPTION]
Installs GUI in your Google Cloud. Written by Akhil T.
If you run this script without any arguments, it installs Xfce in your Google Cloud.
The script only accepts one argument. The arguments are as follows:
If your VM Instance does not have GPU, then Xfce may only work in it.
    xfce                Installs Xfce in your Google Cloud
    cinnamon            Installs Cinnamon in your Google Cloud
    gnome               Installs Gnome in your Google Cloud
    gnome-classic       Installs Gnome-Classic in your Google Cloud
    plasma              Installs KDE Plasma in your Google Cloud
    -h, --help          Display this help and exit" 1>&2
exit;;
xfce|cinnamon|gnome|gnome-classic|plasma)
env=$1;;
*)
echo "Unknown argument: $1
Try '$0 --help' for more information."
exit 1;; esac
else echo "I only accepts 1 argument but you gave $# arguments." 1>&2
exit 2; fi
echo Installing $env in the VM Instance.
if [ ! -e chrome-remote-desktop_current_amd64.deb ]; then echo Downloading https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb; wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb & fi
akhil() { for akhila in "$@"; do
echo Executing the command: $akhila
if ! $akhila; then echo "Error while executing the command: $akhila
Please rectify the errors and rerun the script.
If the issue persists, please refer to this document https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine and manually execute the commands." 1>&2
exit 3; fi; done }
akhil 'sudo apt update'
if [ $(/usr/bin/lsb_release --codename --short) == "stretch" ]; then akhil 'sudo apt install --assume-yes libgbm1/stretch-backports'; fi
case $env in xfce)
akhil 'sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver' 'sudo apt install --assume-yes task-xfce-desktop'
echo Executing the command: sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session';;
cinnamon)
akhil 'sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes cinnamon-core desktop-base dbus-x11' 'sudo apt install --assume-yes task-cinnamon-desktop'
echo Executing the command: sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session'
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session';;
gnome)
akhil 'sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes  task-gnome-desktop'
echo Executing the command: sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session';;
gnome-classic)
akhil 'sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes  task-gnome-desktop'
echo Executing the command: sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session-classic" > /etc/chrome-remote-desktop-session'
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session-classic" > /etc/chrome-remote-desktop-session';;
plasma)
akhil 'sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes  task-kde-desktop'
echo Executing the command: sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/startkde" > /etc/chrome-remote-desktop-session'
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/startkde" > /etc/chrome-remote-desktop-session';; esac
akhil 'sudo systemctl disable lightdm.service'
if ! wait $!; then echo "Failed to download https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb.
Try to download it manually and put the file in the folder where the script stays and rerun the script." 1>&2
exit 4; fi;
akhil 'sudo apt install --assume-yes ./chrome-remote-desktop_current_amd64.deb' 'service chrome-remote-desktop restart'
echo "
$env has been installed in your VM Instance. Now you have to setup Chrome Remote Desktop service.

To start the remote desktop server, you need to have an authorization key for the Google account that you want to use to connect to it:

    In the Cloud Console, go to the VM Instances page.

    Connect to your instance using SSH.

    On your local computer, go to the Chrome Remote Desktop command line setup page:

    https://remotedesktop.google.com/headless

    If you're not already signed in, sign in with a Google Account. This is the account that will be used for authorizing remote access.

    On the Set up another computer page, click Begin.

    On the Download and install Chrome Remote Desktop page, click Next.

    Click Authorize.

    You need to allow Chrome Remote Desktop to access your account. If you approve, the page displays a command line for Debian Linux that looks like the following:

DISPLAY= /opt/google/chrome-remote-desktop/start-host \
    --code=\"4/xxxxxxxxxxxxxxxxxxxxxxxx\" \
    --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" \
    --name=\$(hostname)

You use this command to set up and start the Chrome Remote Desktop service on your VM instance, linking it with your Google Account using the authorization code.
Note: The authorization code in the command line is valid for only a few minutes, and you can use it only once.

Copy the command to the SSH window that's connected to your instance, and then run the command.

When you're prompted, enter a 6-digit PIN. This number will be used for additional authorization when you connect later.

You might see errors like No net_fetcher or Failed to read. You can ignore these errors.

Now you have to connect to the VM Instance using Chrome Remote Desktop web application.

    On your local computer, go to the Chrome Remote Desktop web site.

    https://remotedesktop.google.com/

    Click Remote Access

    If you're not already signed in to Google, sign in with the same Google Account that you used to set up the Chrome Remote Desktop service.

    You see your new VM instance in the Remote Devices list.
    
    Click the name of the remote desktop instance.

    When you're prompted, enter the PIN that you created earlier, and then click the arrow button to connect.

    You are now connected to the desktop environment on your VM instance.
"
if [ $env == 'xfce' ];then echo If you installed the Xfce desktop for the first time, you are prompted to set up the desktop panels. Click Use Default Config to get the standard taskbar at the top and the quick launch panel at the bottom.; else echo $env may not work properly if your VM Instance does not have GPU.; fi
echo; echo If it is taking a long time to connect to the VM Instance or want to restart the Chrome Remote Desktop service, run this command: service chrome-remote-desktop restart; echo