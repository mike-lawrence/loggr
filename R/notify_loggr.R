#' Notify loggr about an event.
#'
#' This is an internal function used by loggr to hook into the relevant
#' events.
#'
#' @param ... arguments passed to the original event.
#' @param type character: either "warning", "error", or "other"
#' @param muffled logical: is the event muffled?
#' @noRd
notify_loggr <- function(..., type = "other", muffled = FALSE)
{
  # Convert information in ... to a log_event
  args <- list(...)
  if (inherits(args[[1L]], "condition")) {
    cond <- args[[1L]]
  } else {
    message = unlist(args)
    message = paste0(message[1:(length(message)-3)],collapse='')
    if (type == "error") {
      # Can we get the call here?
      cond <- simpleError(.makeMessage(message, domain = args[["domain"]]))
    } else if (type == "warning") {
      # Can we get the call here?
      cond <- simpleWarning(.makeMessage(message, domain = args[["domain"]]))
    } else {
      cond <- simpleCondition(.makeMessage(message, domain = args[["domain"]]))
    }
  }
  le <- as_log_event(cond)

  # Send log entry to subscribed log files.
  loggr_objects <- getOption("loggr_objects")
  for (lo in loggr_objects) {
    if (any(toupper(lo$subscriptions) %in% toupper(class(le))) &&
       (!muffled || isTRUE(lo$log_muffled))) {
      write_log_entry(lo, le)
    }
  }

  invisible()
}
