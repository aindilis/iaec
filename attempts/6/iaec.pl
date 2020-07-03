assert(firstName(andrewDougherty,"Andrew")).

findall(X,firstName(andrewDougherty,X),List),==(List,["Andrew"]).
