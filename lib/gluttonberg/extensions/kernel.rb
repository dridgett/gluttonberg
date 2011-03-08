# Returns the locale stored in the current thread. This value is set either 
# explicitly in the backend, or via the DEFER_TO_PROC in the router.
def current_locale
  Thread.current[:locale]
end
