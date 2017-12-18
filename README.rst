About the AnacondaRecipes/aggregate repository
==============================================

The aggregate repository is roughly similar to the concept of the conda-forge feedstocks repository.  It is meant to operate as a centralization of many external repositories, with each of those external repositories following the one-recipe-per-repo concept.  We fork feedstocks from conda-forge, and the long-term goal is to keep in sync with conda-forge recipes.  Unlike the conda-forge feedstocks repository, aggregate also contains some recipes directly in the aggregate repo.  We consider this a temporary staging area for recipes that eventually need to be submitted to conda-forge, or for recipes that we think conda-forge will have no interest in.

How to add new recipes to the aggregate repository
--------------------------------------------------

Unfortunately, because of the structure of this organization, where each recipe has its own repository, there is no way to submit a PR that adds a new recipe, because PRs can’t create repositories, only modify existing ones.  If you’d like to submit a recipe for us to build and make available on the default channel, you can either:

Submit your recipe to conda-forge’s staged-recipes repository (https://github.com/conda-forge/staged-recipes).  There are directions in the readme there: https://github.com/conda-forge/staged-recipes#getting-started When your recipe is merged and has become a feedstock repository, file an issue on the AnacondaRecipes/aggregate repo and we can fork that feedstock repository and build it.
Add your recipe in a folder on the aggregate repository.  This is generally something we’d like to avoid.  It does not benefit from the automated CI building that conda-forge does.  It also mixes up the git history for your recipe with everything else that happens to the aggregate repository.  We’ll still consider recipes submitted this way, but please consider it a last resort.

How to change recipes on the aggregate repository
-------------------------------------------------

Most recipes in the aggregate repository are submodules - essentially links to other repositories.  To submit changes to recipes, it is best to fork those other repositories, submit PRs to them, and then we’ll update the aggregate’s link to the changed recipe.  We prefer PRs to be submitted to conda-forge recipes, because their automatic CI builds help us know that your changes don’t cause any unintended breakage.  Once your changes are incorporated at conda-forge, file an issue on the AnacondaRecipes/aggregate repo and we’ll pull them into our recipe on AnacondaRecipes.

For the few recipes that exist as folders on the aggregate repo, clone the aggregate repo, and issue PRs against it directly.
