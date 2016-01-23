require_relative '../models/init'

Constant.create(key: 'title', label: "Titre principal", help: "Titre de la page d'accueil, qui figure aussi comme titre du navigateur")
Constant.create(key: 'meta_keywords', label: "Meta Keywords", help: "Mot clés permettant un bon référencement du site dans Google")
Constant.create(key: 'meta_description', label: "Meta Description", help: "Le petit paragraphe qui présente le site depuis Google (~150 à 170 caractères)")
Constant.create(key: 'text_contact', label: "Texte page contact", help: "Le texte qui sera sur la page contact.")
Constant.create(key: 'text_accueil', label: "Texte page accueil", help: "Le texte qui sera sur la page d'accueil.")
Constant.create(key: 'last_update', label: "Dernière MAJ", help: "La date de la dernière mise à jour, rajout d'images... Figure sur la page d'accueil.")
Constant.create(key: 'adresse', label: "Adresse", help: "Ton adresse.")
