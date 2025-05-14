#!/bin/bash

install_directory="/var/lib/marzban/templates/subscription/"
template_file="${install_directory}index.html"
env_file="/opt/marzban/.env"

echo "Marzban Pro Template Installation Script"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root"
  exit 1
fi

mkdir -p "$install_directory"

echo "Downloading template..."
wget -N -P "$install_directory" https://raw.githubusercontent.com/Mrclocks/Pro-Subscription-Template/main/index.html

if [ $? -ne 0 ]; then
  echo "Error: Failed to download template. Please check your internet connection."
  exit 1
fi

echo "Configuring Marzban environment..."
if ! grep -q "CUSTOM_TEMPLATES_DIRECTORY=" "$env_file"; then
  echo 'CUSTOM_TEMPLATES_DIRECTORY="/var/lib/marzban/templates/"' | tee -a "$env_file" > /dev/null
fi

if ! grep -q "SUBSCRIPTION_PAGE_TEMPLATE=" "$env_file"; then
  echo 'SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"' | tee -a "$env_file" > /dev/null
fi

echo "Please provide the following information (press Enter to keep default values):"

read -p "Support Link: " support_link
read -p "Page Title/Brand: " page_title
read -p "Logo URL: " logo_url

if [ -n "$support_link" ]; then
  sed -i "1705s|.*|    const supportLink = \"$support_link\";|" "$template_file"
  sed -i "1713s|.*|    const supportLink = \"$support_link\";|" "$template_file"
  echo "Support link updated."
fi

if [ -n "$page_title" ]; then
  sed -i "886s|.*|        <title>$page_title</title>|" "$template_file"
  sed -i "955s|.*|        <span class=\"brand-text\">$page_title</span>|" "$template_file"
  echo "Page title/brand updated."
fi

if [ -n "$logo_url" ]; then
  sed -i "879s|.*|        <link rel=\"icon\" href=\"$logo_url\" type=\"image/x-icon\">|" "$template_file"
  echo "Logo URL updated."
fi

echo "Restarting Marzban..."
if command -v marzban &> /dev/null; then
  marzban restart
  if [ $? -ne 0 ]; then
    echo "Warning: Failed to restart Marzban automatically. Please restart manually."
  else
    echo "Marzban restarted successfully."
  fi
else
  echo "Warning: 'marzban' command not found. Please restart Marzban manually."
fi

echo "Installation and configuration completed successfully!"
echo "You can now access your customized subscription page through your Marzban subscription links."
