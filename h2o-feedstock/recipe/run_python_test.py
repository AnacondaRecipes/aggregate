from h2o import h2o
h2o.init()

# example adapted from http://h2o-release.s3.amazonaws.com/h2o-dev/rel-shannon/2/docs-website/h2o-py/docs/h2o.html#models
fr = h2o.import_file(path="https://raw.githubusercontent.com/h2oai/h2o-2/master/smalldata/logreg/prostate.csv")
r = fr[0].runif()
train = fr[r < 0.70]
test = fr[r >= 0.70]
train["CAPSULE"] = train["CAPSULE"].asfactor()
test["CAPSULE"] = test["CAPSULE"].asfactor()
m = h2o.H2OGeneralizedLinearEstimator(family='binomial', alpha=[0.5])
m.train(x=["AGE", "RACE", "PSA", "VOL", "GLEASON"],
        y="CAPSULE", training_frame=train)
m.show()
