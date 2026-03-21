import 'package:proyecto_recetas/models/recipe.dart';

const dummyRecipes = [
  Recipe(
    id: 'r1',
    title: 'Tostadas de Aguacate',
    type: 'Desayuno',
    isVegan: true,
    isVegetarian: true,
    author: 'Luz M.',
  ),
  Recipe(
    id: 'r2',
    title: 'Pasta Cremosa',
    type: 'Cena',
    isVegan: false,
    isVegetarian: true,
    author: 'Marco R.',
  ),
  Recipe(
    id: 'r3',
    title: 'Ensalada de Quinoa',
    type: 'Comida',
    isVegan: true,
    isVegetarian: true,
    author: 'Sofia G.',
  ),
  Recipe(
    id: 'r4',
    title: 'Pollo al Horno',
    type: 'Cena',
    isVegan: false,
    isVegetarian: false,
    author: 'Carlos P.',
  ),
];
