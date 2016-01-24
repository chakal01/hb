require_relative '../models/init'

Constant.create(key: 'title', label: "Titre principal", help: "Titre de la page d'accueil, qui figure aussi comme titre du navigateur")
Constant.create(key: 'meta_keywords', label: "Meta Keywords", help: "Mot clés permettant un bon référencement du site dans Google")
Constant.create(key: 'meta_description', label: "Meta Description", help: "Le petit paragraphe qui présente le site depuis Google (~150 à 170 caractères)")
Constant.create(key: 'text_contact', label: "Texte contact", help: "Le texte qui sera sur la page contact.", type: "textarea")
Constant.create(key: 'text_accueil', label: "Texte accueil", help: "Le texte qui sera sur la page d'accueil.", type: "textarea")
Constant.create(key: 'news', label: "News", help: "Le texte qui sera sur la page d'accueil.", type: "textarea")
Constant.create(key: 'address', label: "Adresse", help: "Ton adresse.", type: "textarea")
