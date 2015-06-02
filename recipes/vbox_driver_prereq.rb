execute 'pip install pyremotevbox' do
  not_if 'pip list | grep pyremotevbox'
end
