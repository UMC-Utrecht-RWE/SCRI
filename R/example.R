# StudyPopulation <- readRDS(system.file("extdata", "StudyPopulation.rds", package = "SCRI"))
#           WindowsMetadata <- readRDS(system.file("extdata", "WindowsMetadata.rds", package = "SCRI"))
#           usethis::use_data(StudyPopulation)
#           usethis::use_data(WindowsMetadata)
#
#           windowmet <- WindowsMetadata[grepl("post",WindowsMetadata$window_name),]
#           SCRI::compute_windows(studypop, windowmet)
