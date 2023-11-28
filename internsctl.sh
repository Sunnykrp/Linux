#!/bin/bash

# Function for the --help option
display_help() {
    echo "Usage: internsctl [OPTIONS] COMMAND"
    echo "Options:"
    echo "  --help             Display this help message"
    echo "  --version          Display command version"
    echo ""
    echo "Commands:"
    echo "  cpu getinfo        Display CPU information"
    echo "  memory getinfo     Display memory information"
    echo "  user create        Create a new user"
    echo "  user list          List all users"
    echo "  user list --sudo-only   List users with sudo permissions"
    echo "  file getinfo       Display file information"
    echo ""
    echo "For more information on a specific command, use:"
    echo "  internsctl COMMAND --help"
}

# Function for the --version option
display_version() {
    echo "internsctl v0.1.0"
}

# Function to get CPU information
get_cpu_info() {
    lscpu
}

# Function to get Memory information
get_memory_info() {
    free
}

# Function to create a new user
create_user() {
    if [ $# -ne 1 ]; then
        echo "Usage: internsctl user create <username>"
        return 1
    fi
    sudo adduser "$1"
}

# Function to list users
list_users() {
    cut -d: -f1 /etc/passwd
}

# Function to list users with sudo permissions
list_sudo_users() {
    grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
}

# Function to get file information with specific options
get_file_info() {
    local option="$1"
    local file="$2"

    if [ "$option" == "--size" ]; then
        stat -c %s "$file"
    elif [ "$option" == "--permissions" ]; then
        stat -c %A "$file"
    elif [ "$option" == "--owner" ]; then
        stat -c %U "$file"
    elif [ "$option" == "--last-modified" ]; then
        stat -c '%y' "$file"
    else
        echo "Invalid option: $option"
        return 1
    fi
}

# Main script logic
case "$1" in
    "--help")
        display_help
        ;;
    "--version")
        display_version
        ;;
    "cpu")
        case "$2" in
            "getinfo")
                get_cpu_info
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "memory")
        case "$2" in
            "getinfo")
                get_memory_info
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "user")
        case "$2" in
            "create")
                create_user "$3"
                ;;
            "list")
                if [ "$3" == "--sudo-only" ]; then
                    list_sudo_users
                else
                    list_users
                fi
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "file")
        case "$2" in
            "getinfo")
                if [ $# -lt 3 ]; then
                    echo "Usage: internsctl file getinfo [OPTIONS] <file-name>"
                    exit 1
                fi
                get_file_info "$3" "$4"
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    *)
        display_help
        ;;
esac

# End of script

