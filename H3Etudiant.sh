#!/bin/bash
# Titre: Hop3xEtudiant.sh
# Script pour Lancer le programme Hop3xEtudiant version pour les nulls
# il gère également l'installation des dépendances nécessaires
# et l'installation du programme Hop3xEtudiant
# Auteur: JACOBONI Pierre, DESPRES Christophe, PUREN Mewen
# Date: 2021-09-30
# Version: 2.0
# Basée sur le script de lancement de Hop3xEtudiant de 
# monsieurs JACOBONI et DESPRES enseigant chercheur à l'Université du Maine
# L'entièreté des droits d'auteurs reviennent à monsieurs JACOBONI, DESPRES et aux LIUM/DeptInfo
# Lutilisation et la modification de ce script est libre et gratuite
# https://hal.science/hal-01457592
# https://hop3x.univ-lemans.fr/




################################
##----VARIABLES MODIFIABLE----##
################################

# Liste des dépendances apt requises pour le programme Hop3xEtudiant
dependencies=(
    "unzip"                     # Utilitaire de décompression
    "wget"                      # Utilitaire de téléchargement
    "gcc"                       # Compilateur C GNU
    "libc6-dev"                 # Bibliothèque C GNU
    "make"                      # Utilitaire de construction
    "xterm"                     # Terminal X
    "ruby"                      # Langage de programmation
    "ruby-dev"                  # Fichier de développement Ruby
    "glade"                     # Interface graphique pour GTK
    "gobject-introspection"     # Introspection d'objet pour GTK
    "libgirepository1.0-dev"    # Bibliothèque de développement pour l'introspection d'objet
)

# Liste des dépendances gem requises pour le programme Hop3xEtudiant
gems=(
    "gtk3"          # Interface graphique GTK pour Ruby
    "rake"          # Utilitaire de construction Ruby
)

####################################
##----VARIABLES NON MODIFIABLE----##
####################################

# Drapeaux et variables pour suivre les dépendances manquantes
missing_dependencies=false  # Indique si des dépendances sont manquantes
missing_packages=""         # Liste des paquets manquants
missing_gem=""              # Liste des gems manquants

# Couleurs
RED='\033[0;31m'        # Rouge pour les erreurs
GREEN='\033[0;32m'      # Vert pour les succès
NC='\033[0m'            # Réinitialisation de la couleur

################################
##----FONCTIONS DU SCRIPT----##
################################

##----JAVA----##
# Fonction pour vérifier si java est installé avec une version supérieure a 11
check_java() {

    # verifier si java est installé
    if ! [ -x "$(command -v java)" ]; then
        echo -e "${RED}Error: Java is not installed.${NC}" >&2
        exit 1
    else
        echo -e "${GREEN}Java is installed.${NC}"
    fi

    # verifier si la version de java est supérieure a 11
    if [[ $(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1) -lt 11 ]]; then
        echo -e "${RED}Error: Java version is less than 11.${NC}" >&2
        exit 1
    else
        echo -e "${GREEN}Java version is greater than 11.${NC}"
    fi
}

##----APT----##
# verifier les dépendances apt
check_apt() {

    missing_dependencies=false  # Réinitialiser le drapeau des dépendances manquantes
    missing_packages=""         # Réinitialiser la liste des paquets manquants

    # Fonction pour vérifier si une commande est installée
    check_command() {
        which "$1" >/dev/null
    }

    # Fonction pour vérifier si un paquet est installé
    check_package() {
        dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
    }

    # Vérifier chaque dépendance de la liste
    for dep in "${dependencies[@]}"; do
        if ! check_command "$dep"; then # par du principe que si le which ne trouve pas la commande c'est peut être un paquet
            if ! check_package "$dep"; then # si le paquet n'est pas installé
                missing_dependencies=true
                missing_packages="$missing_packages $dep"
                echo -e "${RED}$dep is not installed.${NC}" >&2
            fi
        fi
    done

    # Si des dépendances sont manquantes, afficher un message d'erreur et générer la commande apt-get install
    if $missing_dependencies; then
        echo -e "${RED}Error: Missing dependencies${NC}" >&2
        if [ -n "$missing_packages" ]; then
            echo "les paquets suivants sont manquants : $missing_packages"
            echo "il vont être installés"
            echo "sudo apt install -y $missing_packages"
            sudo apt update
            if ! eval "sudo apt install -y $missing_packages"; then
                echo -e "${RED}Error: Failed to install dependencies.${NC}" >&2
                exit 1
            fi
        fi
    fi


    echo -e "${GREEN}All dependencies are installed.${NC}"
}

##----GEM----##
# Vérifier les dépendances gem
check_gem() {

    missing_dependencies=false  # Réinitialiser le drapeu des dépendances manquantes
    missing_gem=""              # Réinitialiser la liste des gems manquants

    # Fonction pour vérifier si un gem est installé
    for gem in "${gems[@]}"; do
        if ! gem list "$gem" -i >/dev/null; then
            echo -e "${RED}Gem $gem is not installed.${NC}" >&2
            missing_dependencies=true
            missing_gem="$missing_gem $gem"
        fi
    done

    # Si des dépendances sont manquantes, afficher un message d'erreur et générer la commande gem install
    if $missing_dependencies; then
        echo -e "${RED}Error: Missing dependencies${NC}" >&2
        if [ -n "$missing_gem" ]; then
            echo "les gems suivants sont manquants : $missing_gem"
            echo "il vont être installés"
            if ! eval "sudo gem install $missing_gem"; then
                echo -e "${RED}Error: Failed to install gems.${NC}" >&2
                exit 1
            fi
        fi
    fi
    echo -e "${GREEN}All gems are installed.${NC}"
}

##----HOP3X----##
# Vérifier si le programme Hop3xEtudiant est installé
check_hop3x() {

    install_hop3x() {
        echo -e "${GREEN}Installation de Hop3xEtudiant...${NC}"
        wget https://hop3x.univ-lemans.fr/Hop3xEtudiant.zip
        mkdir prison
        cp H3Etudiant.sh prison
        unzip -o Hop3xEtudiant.zip
        rm Hop3xEtudiant.zip
        rm H3Etudiant.sh
        mv prison/H3Etudiant.sh .
        rm -fr prison
        echo -e "${GREEN}Hop3xEtudiant est installé.${NC}"
    }

    if [ ! -d "hop3xEtudiant" ]; then
        echo -e "${RED}Error: Hop3xEtudiant is not installed.${NC}" >&2
        install_hop3x
    else
        echo -e "${GREEN}Hop3xEtudiant is installed.${NC}"
    fi
}

##################################
##----EXECUTION DU PROGRAMME----##
##################################

# Vérifier si java est installé
check_java

# Vérifier les dépendances apt
check_apt

# Vérifier les dépendances gem
check_gem

# Vérifier si le programme Hop3xEtudiant est installé
check_hop3x

# Lancer l'application
java -Xmx2048m -jar hop3xEtudiant/lib/Hop3xEtudiant.jar
