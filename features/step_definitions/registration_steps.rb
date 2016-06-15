Then(/^vbguest additions should( not)? be installed$/) do |negated|
  run("vagrant ssh -c \"lsmod | grep -i vbox\"")

  if negated
    expect(last_command_started).to have_exit_status(1)
    expect(last_command_started).not_to have_output(/vboxguest/)
  else
    expect(last_command_started).to have_exit_status(0)
    expect(last_command_started).to have_output(/vboxguest/)
  end
end

Then(/^startup should fail with invalid credentials error$/) do
  expect(last_command_started).to have_exit_status(1)
  expect(last_command_started).to have_output(/Invalid username or password./)
end

