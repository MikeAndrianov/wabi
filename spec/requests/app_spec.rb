# frozen_string_literal: true

describe App do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  context 'get to /' do
    let(:response) { get '/' }

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to include('Hello world') }
  end

  context 'get to /about' do
    let(:response) { get '/about' }

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to include('About') }
  end

  context 'post to /google' do
    let(:response) { post '/google' }

    it { expect(response.status).to eq(201) }
    it { expect(response.headers).to include('Location' => 'http://google.com') }
    it { expect(response.body).to be_empty }
  end

  context 'get to /profile/:id' do
    let(:response) { get '/profile/12' }

    it { expect(response.status).to eq(201) }
    it { expect(response.headers).to include('Content-Type' => 'application/json') }
    it { expect(JSON.parse(response.body)).to include('id' => '12') }
  end

  context 'post to /s/:article_slug/comments/:id' do
    let(:response) { post '/s/first_article/comments/7' }

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to include('article_slug, id') }
  end
end
