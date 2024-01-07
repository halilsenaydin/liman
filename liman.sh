#!/bin/bash
FileLogger(){
	# log: date exec_command message status
	log_file_name="liman_log.log";
	command="$1";
	message="$2";
	status="$3";
	echo "$(date) __ "$command" __ "$message" __ "$status"" >> "$log_file_name";
}

ExecCommand(){
	command="$1";
	caption="$2";
	echo "$command" | bash;
	if [ "$?" -ne 0 ]
	then
		message="$caption İşlemi Başarısız.";
		echo -e "\n$message\n";
		echo -e "\nÇalıştırılan Komut: $command\n";
		FileLogger "$command" "$message" "false";
		exit 1;
		# return 1; # Command exec failed
	fi
	
	message="$caption İşlemi Başarılı.";
	echo -e "\n$message\n";
	FileLogger "$command" "$message" "true";
	return 0; # Command exec success
}

GetInfoAboutScript(){
	echo "Script hakkında bilgi almak için -h veya --help seçeneği kullanılmalıdır.";
	echo "'./liman.sh -h' veya './liman.sh --help'";
}

if [ "$#" -lt 1 ]; then
    echo "Script en az bir parametre almalıdır.";
    exit 1;
fi

operation="$1";

if [[ "$operation" = "-i" || "$operation" = "--install" ]]
then
	FileLogger "$0" "Liman Kurulumu Başlatıldı." "true";
	
	# Installing liman
	echo -e "Liman MYS kurulumu başladı.\n";
	
	# Adding updated PHP
	ExecCommand "sudo apt install software-properties-common" "PHP PPA Ekleme";
	ExecCommand "sudo add-apt-repository ppa:ondrej/php" "PHP Repo Ekleme";
	ExecCommand "sudo apt update" "PHP Kurulum";

	# Installing Node
	ExecCommand "sudo apt install -y ca-certificates curl gnupg gnupg2" "Node İçin Gerekli Paketlerin Kurulum";
	sudo mkdir -p /etc/apt/keyrings;
	curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg;
	ExecCommand 'echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list' "Node Repo Ekleme";
	ExecCommand "sudo apt update" "Node Kurulum";
	
	# Installing PostgreSQL
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list';
	ExecCommand "wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > pgsql.gpg" "PostgreSQL Repo Ekleme";
	sudo mv pgsql.gpg /etc/apt/trusted.gpg.d/pgsql.gpg;
	ExecCommand "sudo apt update" "PostgreSQL Kurulum";
	
	# Install liman package
	ExecCommand "wget https://github.com/limanmys/core/releases/download/release.feature-new-ui.860/liman-2.0-RC2-860.deb" "Liman Dosyasını İndirme";
	sudo chmod 644 /root/liman-2.0-RC2-860.deb
	ExecCommand "sudo apt install ./liman-2.0-RC2-860.deb -y" "Liman Dosyasının Kurulum";

	# Install liman package from repo
	ExecCommand "sudo apt update" "apt update";
	ExecCommand "sudo apt install liman" "Liman Kurulum";
	
	ExecCommand "sudo limanctl administrator" "Liman Admin Hesabı Oluşturma";
	
	# Show working port
	echo "----------------------------------------";
	ss -nutlp
	echo "----------------------------------------";

elif [[ "$operation" = "-a" || "$operation" = "--admin" ]]
then
	FileLogger "$0" "Admin Reset İşlemi Başlatıldı." "true";
	ExecCommand "sudo limanctl reset administrator@liman.dev" "Admin reset" ;

elif [[ "$operation" = "-r" || "$operation" = "--reset" ]]
then
	FileLogger "$0" "Liman MYS Sıfırlama İşlemi Başlatıldı." "true";
        if [ "$#" -ne 2 ]; then
            echo "-r veya --reset seçeneği, <mail> parametresi beklemektedir. './liman.sh -r administrator@liman.dev'";
            exit 1
        fi
        
	# Reset
	ExecCommand "sudo limanctl reset "$2"" "Sıfırlama";
	echo "Liman MYS başarıyla sıfırlandı.";

elif [[ "$operation" = "-p" || "$operation" = "--purge" ]]
then
	FileLogger "$0" "Liman MYS Kaldırma İşlemi Başlatıldı." "true";
	
	# Purge liman
        echo "Liman MYS kaldırma işlemi başlatılıyor.";

	# Stop Liman
        sudo systemctl stop liman;

        # Remove Liman
        ExecCommand "sudo apt remove liman -y" "Liman Kaldırma";

        # Remove dependencies
        ExecCommand "sudo apt autoremove -y" "Gereksiz Bağımlılıkları Kaldırma";

        # Remove etc files and db files
        ExecCommand "sudo rm -rf /etc/liman" "Konfigürasyon Dosyalarını Kaldırma";
        ExecCommand "sudo rm -rf /var/lib/liman" "Veri Tabanı Dosyalarını Kaldırma";
        
        # Delete liman user and group
        sudo pkill -u liman;
        ExecCommand "sudo deluser liman" "Liman Kullanıcısını Kaldırma";
        ExecCommand "sudo groupdel liman" "Liman Grubunu Kaldırma";

        echo "Liman MYS 2.0 başarıyla kaldırıldı.";

elif [[ "$operation" = "-h" || "$operation" = "--help" ]]
then
	# Help about script
	echo "./liman.sh -i | --install -> Insall Liman";
	echo "./liman.sh -a | --admin   -> Create Admin Accound";
	echo "./liman.sh -r | --reset   -> Reset Admin Account If Forgat Your Password";
	echo "./liman.sh -p | --purge   -> Remove Liman";
	echo "./liman.sh -h | --help    -> Help About Script";

else
    echo "'$1' Geçersiz Seçenek!";
    GetInfoAboutScript;
    exit 1;
fi
