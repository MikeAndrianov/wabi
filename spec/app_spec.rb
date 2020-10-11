describe App do
  let(:app) { App.new }

  context 'get to /' do
    let(:response) { get '/' }

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to include('Hello world') }
  end
end
