require 'rails_helper'

RSpec.describe Oracle::Employee, type: :model do

# Scott Drysdale
  let(:testNetidAS)    { 'd19125j'.upcase }
  let(:testSurnameAS)  { 'Drysdale' }

# Tom Trimarco
  let(:testNetidGSM)   { 'd83637s'.upcase }
  let(:testSurnameGSM) { 'Trimarco' }

  it 'does not throw an error' do
    expect { Oracle::Employee.count(:distinct => true) }.not_to raise_error
  end

  it 'has one or more rows' do
    expect(Oracle::Employee.count(:distinct => true)).to be > 0
  end

  it 'has an A+S row we know about' do
####    puts("Oracle::Employee has the following methods:\n\t",
####         Oracle::Employee.methods.sort.join("\n\t").to_s)
    puts(Oracle::Employee.find_by(username: testNetidAS).email)
    expect(Oracle::Employee.find_by(username: testNetidAS).lastname).to eql(testSurnameAS)
####    puts("employee has the following methods:\n\t",
####         employee.methods.sort.join("\n\t").to_s)
  end

  it 'has a GSM row we know about' do
    puts(Oracle::Employee.find_by(username: testNetidGSM).email)
    expect(Oracle::Employee.find_by(username: testNetidGSM).lastname).to eql(testSurnameGSM)
  end

end
