{-# OPTIONS --without-K --exact-split --safe #-}

module Inhabitation where

open import Universes
open import MLTT-Agda
open import HoTT-UF-Agda
open import FunExt

is-inhabited : 𝓤 ̇ → 𝓤 ⁺ ̇
is-inhabited {𝓤} X = (P : 𝓤 ̇ ) → is-subsingleton P → (X → P) → P

global-dfunext : 𝓤ω
global-dfunext = ∀ 𝓤 𝓥 → dfunext 𝓤 𝓥

inhabitation-is-a-subsingleton : global-dfunext → (X : 𝓤 ̇ ) → is-subsingleton (is-inhabited X)
inhabitation-is-a-subsingleton {𝓤} fe X =
  Π-is-subsingleton (fe (𝓤 ⁺) 𝓤)
    λ P → Π-is-subsingleton (fe 𝓤 𝓤)
           (λ (s : is-subsingleton P)
                 → Π-is-subsingleton (fe 𝓤 𝓤) (λ (f : X → P) → s))

pointed-is-inhabited : {X : 𝓤 ̇ } → X → is-inhabited X
pointed-is-inhabited x = λ P s f → f x

inhabited-recursion : (X P : 𝓤 ̇ ) → is-subsingleton P → (X → P) → is-inhabited X → P
inhabited-recursion X P s f φ = φ P s f

inhabited-gives-pointed-for-subsingletons : (P : 𝓤 ̇ ) → is-subsingleton P → is-inhabited P → P
inhabited-gives-pointed-for-subsingletons P s = inhabited-recursion P P s id

inhabited-functorial : global-dfunext → (X : 𝓤 ⁺ ̇ ) (Y : 𝓤 ̇ )
                     → (X → Y) → is-inhabited X → is-inhabited Y
inhabited-functorial fe X Y f = inhabited-recursion
                                  X
                                  (is-inhabited Y)
                                  (inhabitation-is-a-subsingleton fe Y)
                                  (pointed-is-inhabited ∘ f)

image : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → (X → Y) → (𝓤 ⊔ 𝓥)⁺ ̇
image f = Σ \(y : codomain f) → is-inhabited (Σ \(x : domain f) → f x ≡ y)

restriction : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } (f : X → Y)
            → image f → Y
restriction f (y , _) = y

corestriction : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } (f : X → Y)
              → X → image f
corestriction f x = f x , pointed-is-inhabited (x , refl (f x))

is-surjection : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → (X → Y) → (𝓤 ⊔ 𝓥)⁺ ̇
is-surjection f = (y : codomain f) → is-inhabited (Σ \(x : domain f) → f x ≡ y)

record propositional-truncations-exist : 𝓤ω where
 field
  ∥_∥ : {𝓤 : Universe} → 𝓤 ̇ → 𝓤 ̇
  ∥∥-is-a-prop : {𝓤 : Universe} {X : 𝓤 ̇ } → is-prop ∥ X ∥
  ∣_∣ : {𝓤 : Universe} {X : 𝓤 ̇ } → X → ∥ X ∥
  ∥∥-rec : {𝓤 𝓥 : Universe} {X : 𝓤 ̇ } {P : 𝓥 ̇ } → is-prop P → (X → P) → ∥ X ∥ → P

module basic-truncation-development
         (pt : propositional-truncations-exist)
         (fe : global-dfunext)
       where

  open propositional-truncations-exist pt public

  ∥∥-functor : {X : 𝓤 ̇ } {Y : 𝓥 ̇} → (X → Y) → ∥ X ∥ → ∥ Y ∥
  ∥∥-functor f = ∥∥-rec ∥∥-is-a-prop (λ x → ∣ f x ∣)

  ∃ : {X : 𝓤 ̇ } → (Y : X → 𝓥 ̇ ) → 𝓤 ⊔ 𝓥 ̇
  ∃ Y = ∥ Σ Y ∥

  ∥∥-agrees-with-inhabitation : (X : 𝓤 ̇) → ∥ X ∥ ⇔ is-inhabited X
  ∥∥-agrees-with-inhabitation X = a , b
   where
    a : ∥ X ∥ → is-inhabited X
    a = ∥∥-rec (inhabitation-is-a-subsingleton fe X) pointed-is-inhabited
    b : is-inhabited X → ∥ X ∥
    b = inhabited-recursion X ∥ X ∥ ∥∥-is-a-prop ∣_∣

  AC : ∀ 𝓣 (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ )
    → is-set X → ((x : X) → is-set (A x)) → 𝓣 ⁺ ⊔ 𝓤 ⊔ 𝓥  ̇
  AC 𝓣 X A i j = (R : (x : X) → A x → 𝓣 ̇ )
               → ((x : X) → ∃ \(a : A x) → R x a)
               → ∃ \(f : (x : X) → A x) → (x : X) → R x (f x)

  Choice : ∀ 𝓤 → 𝓤 ⁺ ̇
  Choice 𝓤 = (X : 𝓤 ̇ ) (A : X → 𝓤 ̇ )
             (i : is-set X) (j : (x : X) → is-set (A x))
           → AC 𝓤 X A i j

  IAC : (X : 𝓤 ̇ ) (Y : X → 𝓥 ̇ )
      → is-set X → ((x : X) → is-set (Y x)) → 𝓤 ⊔ 𝓥 ̇
  IAC X Y i j = ((x : X) → ∥ Y x ∥) → ∥ Π Y ∥

  IChoice : ∀ 𝓤 → 𝓤 ⁺ ̇
  IChoice 𝓤 = (X : 𝓤 ̇ ) (Y : X → 𝓤 ̇ )
             (i : is-set X) (j : (x : X) → is-set (Y x))
            → IAC X Y i j

{- TODO
  Choice-gives-IChoice : Choice 𝓤 → IChoice 𝓤
  Choice-gives-IChoice ac X Y i j φ = {!!}

  IChoice-gives-Choice : IChoice 𝓤 → Choice 𝓤
  IChoice-gives-Choice = {!!}
-}

