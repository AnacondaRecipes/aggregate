About the AnacondaRecipes/aggregate repository
==============================================

The aggregate repository contains:

-  The global `conda-build variant config <https://docs.conda.io/projects/conda-build/en/latest/resources/variants.html#creating-conda-build-variant-config-files>`_ file: `conda_build_config.yaml <https://github.com/AnacondaRecipes/aggregate/blob/master/conda_build_config.yaml>`_ (similar to the `conda-forge-pinnings-feedstock <https://github.com/conda-forge/conda-forge-pinning-feedstock/blob/master/recipe/conda_build_config.yaml>`_)
-  A central list of all public maintained feedstocks:

   -  most feedstocks are separate feedstock repositories:

      -  They are referenced as git submodule with relative repository URL and their release branches: `.gitmodules <https://github.com/AnacondaRecipes/aggregate/blob/master/.gitmodules>`_. (similar to ``conda-forge`` feedstocks repository)
      -  The quality on the referenced release branches is ensured via *Pull Requests* and *Automated builds*. The latest commit can be checked out via: ``git submodule update --init --remote $feedstock-folder`` (``--remote`` is important as the submodule pinning to a specific sha1 of the referenced repository is often not updated.)

   -  some feedstocks are normal directories checked into aggregate: aggregate serves here as staging area for recipes that eventually need to be submitted to ``conda-forge`` or for recipes that we think ``conda-forge`` will have no interest in.

How to add new recipes to the aggregate repository
--------------------------------------------------

Unfortunately, because of the structure of this organization, where each recipe has its own repository, there is no way to submit a PR that adds a new recipe, because PRs can’t create repositories, only modify existing ones. If you’d like to submit a recipe for us to build and make available on the default channel, you can either:

-  Submit your recipe to conda-forge’s staged-recipes repository (https://github.com/conda-forge/staged-recipes). There are directions in `the readme here <https://github.com/conda-forge/staged-recipes#getting-started>`_. When your recipe is merged and has become a feedstock repository, file an issue on the ``AnacondaRecipes/aggregate`` repo and we can fork that feedstock repository and build it.
-  Add your recipe in a folder on the aggregate repository. **This is generally something we’d like to avoid.** It does not benefit from the automated CI building that ``conda-forge`` does. It also mixes up the git history for your recipe with everything else that happens to the aggregate repository. We’ll still consider recipes submitted this way, but please consider it a last resort.

How to change recipes on the aggregate repository
-------------------------------------------------

Most recipes in the aggregate repository are submodules - essentially links to other repositories. To submit changes to recipes, it is best to fork those other repositories, submit PRs to them, and then we’ll update the aggregate’s link to the changed recipe. We prefer PRs to be submitted to ``conda-forge`` recipes, because their automatic CI builds help us know that your changes don’t cause any unintended breakage. Once your changes are incorporated at conda-forge, file an issue on the ``AnacondaRecipes/aggregate`` repo and we’ll pull them into our recipe on AnacondaRecipes.

For the few recipes that exist as folders on the aggregate repo, clone the aggregate repo, and issue PRs against it directly.

How to build python + packages once a new version of Python arrives (on ppc)
----------------------------------------------------------------------------

::

  CONDA_ADD_PIP_AS_PYTHON_DEPENDENCY=0 \
    conda-build $(cat python-order.txt | \
        sed '/^python-feedstock/,$!d' | \
        grep -v '# \[not ppc\]' | \
        sed 's/[[:space:]].*$//' | tr '\n' ' ') \
      -c local \
      -c https://repo.anaconda.com/pkgs/main \
      --skip-existing --error-overlinking 2>&1 | \
    tee -a ~/conda/python-3.7.0-all-build-out.log
