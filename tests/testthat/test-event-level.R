test_that("`event_level` is passed through in tune_grid()", {
  skip_if_not_installed("modeldata")
  skip_if_not_installed("randomForest")

  set.seed(123)

  data("two_class_dat", package = "modeldata")
  dat <- two_class_dat[1:50,]

  spec <- parsnip::rand_forest(mode = "classification", trees = tune()) %>%
    parsnip::set_engine("randomForest")

  control <- control_grid(event_level = "second", save_pred = TRUE)
  resamples <- rsample::bootstraps(dat, times = 1)
  set <- yardstick::metric_set(yardstick::roc_auc, yardstick::sens)
  grid <- tibble::tibble(trees = 2L)

  result <- tune_grid(
    spec,
    Class ~ .,
    resamples = resamples,
    metrics = set,
    grid = grid,
    control = control
  )

  metrics <- result$.metrics[[1]]
  estimates <- metrics$.estimate
  predictions <- result$.predictions[[1]]

  expected_sens <- yardstick::sens_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_class,
    event_level = "second"
  )

  expected_roc_auc <- yardstick::roc_auc_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_Class2,
    event_level = "second"
  )

  expect_identical(estimates[metrics$.metric == "sens"], expected_sens)
  expect_identical(estimates[metrics$.metric == "roc_auc"], expected_roc_auc)
})

test_that("`event_level` is passed through in fit_resamples()", {
  skip_if_not_installed("modeldata")
  skip_if_not_installed("randomForest")

  set.seed(123)

  data("two_class_dat", package = "modeldata")
  dat <- two_class_dat[1:50,]

  spec <- parsnip::rand_forest(mode = "classification", trees = 2) %>%
    parsnip::set_engine("randomForest")

  control <- control_resamples(event_level = "second", save_pred = TRUE)
  resamples <- rsample::bootstraps(dat, times = 1)
  set <- yardstick::metric_set(yardstick::roc_auc, yardstick::sens)

  result <- fit_resamples(
    spec,
    Class ~ .,
    resamples = resamples,
    metrics = set,
    control = control
  )

  metrics <- result$.metrics[[1]]
  estimates <- metrics$.estimate
  predictions <- result$.predictions[[1]]

  expected_sens <- yardstick::sens_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_class,
    event_level = "second"
  )

  expected_roc_auc <- yardstick::roc_auc_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_Class2,
    event_level = "second"
  )

  expect_identical(estimates[metrics$.metric == "sens"], expected_sens)
  expect_identical(estimates[metrics$.metric == "roc_auc"], expected_roc_auc)
})

test_that("`event_level` is passed through in tune_bayes()", {
  skip_if_not_installed("modeldata")
  skip_if_not_installed("randomForest")

  set.seed(123)

  data("two_class_dat", package = "modeldata")
  dat <- two_class_dat[1:50,]

  spec <- parsnip::rand_forest(mode = "classification", trees = tune()) %>%
    parsnip::set_engine("randomForest")

  control_grid <- control_grid(save_pred = TRUE)
  control <- control_bayes(event_level = "second", save_pred = TRUE)
  resamples <- rsample::bootstraps(dat, times = 1)
  set <- yardstick::metric_set(yardstick::roc_auc, yardstick::sens)

  result <- tune_bayes(
    spec,
    Class ~ .,
    resamples = resamples,
    metrics = set,
    iter = 1,
    control = control
  )

  result <- result[result$.iter == 1,]

  metrics <- result$.metrics[[1]]
  estimates <- metrics$.estimate
  predictions <- result$.predictions[[1]]

  expected_sens <- yardstick::sens_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_class,
    event_level = "second"
  )

  expected_roc_auc <- yardstick::roc_auc_vec(
    truth = predictions$Class,
    estimate = predictions$.pred_Class2,
    event_level = "second"
  )

  expect_identical(estimates[metrics$.metric == "sens"], expected_sens)
  expect_identical(estimates[metrics$.metric == "roc_auc"], expected_roc_auc)
})
