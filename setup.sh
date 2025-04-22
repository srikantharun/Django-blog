#!/bin/bash

# Define colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section header
print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

# Function to check command execution
check_command() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Success:${NC} $1"
    else
        echo -e "${RED}✗ Error:${NC} $1"
        exit 1
    fi
}

# Start script
print_header "Django Blog Setup Script"
echo "This script will set up your Django blog application"

# Install dependencies
print_header "Installing dependencies"
pip install -r requirements.txt
check_command "Dependencies installed"

# Set up environment variables
print_header "Setting up environment variables"
if [ ! -f ".env" ]; then
    cat > .env << EOF
DEBUG=True
SECRET_KEY=django-insecure-$(openssl rand -base64 32)
ALLOWED_HOSTS=localhost,127.0.0.1
EOF
    check_command "Environment variables created"
else
    echo -e "${YELLOW}⚠ Notice:${NC} .env file already exists, skipping"
fi

# Run migrations
print_header "Running database migrations"
python manage.py makemigrations accounts
python manage.py makemigrations blog
python manage.py migrate
check_command "Database migrations completed"

# Create superuser
print_header "Creating superuser"
echo -e "${YELLOW}Enter superuser details:${NC}"
python manage.py createsuperuser

# Run the initialization script
print_header "Running template initialization script"
chmod +x initialize.sh
./initialize.sh

# Create media directory
print_header "Creating media directory"
mkdir -p media/profile_pics
mkdir -p media/blog_images
check_command "Media directories created"

# Final message
print_header "Setup Complete!"
echo -e "${GREEN}Your Django blog is now set up and ready to use!${NC}"
echo ""
echo "To start the development server:"
echo "  python manage.py runserver"
echo ""
echo "Then visit: http://127.0.0.1:8000"
echo ""
echo "Admin interface: http://127.0.0.1:8000/admin"
echo "Login with the superuser credentials you just created."

# Start the server
print_header "Starting development server"
echo "The server will start at http://127.0.0.1:8000"
echo "Press Ctrl+C to stop the server"
python manage.py runserver
